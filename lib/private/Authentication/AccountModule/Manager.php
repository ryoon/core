<?php
/**
 * @author Jörn Friedrich Dreyer <jfd@butonic.de>
 *
 * @copyright Copyright (c) 2018, ownCloud GmbH
 * @license AGPL-3.0
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License, version 3,
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 */

namespace OC\Authentication\AccountModule;

use OC\Authentication\Exceptions\AccountCheckException;
use OC\NeedsUpdateException;
use OCP\App\IAppManager;
use OCP\AppFramework\QueryException;
use OCP\Authentication\IAccountModule;
use OCP\IConfig;
use OCP\ILogger;
use OCP\IUser;

class Manager {

	/** @var IConfig */
	private $config;

	/** @var ILogger */
	private $logger;

	/** @var IAppManager */
	private $appManager;

	/**
	 * @param IConfig $config
	 * @param ILogger $logger
	 * @param IAppManager $appManager
	 */
	public function __construct(IConfig $config, ILogger $logger, IAppManager $appManager) {
		$this->config = $config;
		$this->logger = $logger;
		$this->appManager = $appManager;
	}

	/**
	 * Get the list of account modules for the given user
	 * Limited to auth-modules that are enabled for this user
	 *
	 * @param IUser $user
	 * @return IAccountModule[]
	 */
	public function getAccountModules(IUser $user) {
		$modules = [];

		foreach ($this->appManager->getEnabledAppsForUser($user) as $appId) {
			$info = $this->appManager->getAppInfo($appId);
			if (isset($info['account-modules'])) {
				$moduleClasses = $info['account-modules'];
				foreach ($moduleClasses as $className) {
					$this->loadAccountModuleApp($appId);
					try {
						$module = \OC::$server->query($className);
						$modules[$className] = $module;
					} catch (QueryException $e) {
						$this->logger->logException($e);
					}
				}
			}
		}

		// load order from appconfig
		$rawOrder = $this->config->getAppValue('core', 'account-module-order', '[]');
		$order = \json_decode($rawOrder);
		if (!\is_array($order)) {
			$order = [];
		}

		// replace class name with instance
		foreach ($order as $i => $className) {
			if (isset($modules[$className])) {
				unset($modules[$className]);
				$order[$i] = $modules[$className];
			} else {
				unset($order[$i]);
			}
		}
		// add unordered modules
		foreach ($modules as $className => $instance) {
			$order[] = $instance;
		}

		return $order;
	}

	/**
	 * Load an app by ID if it has not been loaded yet
	 *
	 * @param string $appId
	 */
	protected function loadAccountModuleApp($appId) {
		if (!\OC_App::isAppLoaded($appId)) {
			try {
				\OC_App::loadApp($appId);
			} catch (NeedsUpdateException $e) {
				$this->logger->logException($e);
			}
		}
	}

	/**
	 * @param IUser $user
	 * @throws AccountCheckException
	 */
	public function check(IUser $user) {
		foreach ($this->getAccountModules($user) as $accountModule) {
			try {
				$accountModule->check($user);
			} catch (AccountCheckException $ex) {
				$this->logger->debug('IAccountModule check failed: {message}, {code}', [
					'app'=>__METHOD__,
					'message' => $ex->getMessage(),
					'code' => $ex->getCode()
				]);
				throw $ex;
			}
		}
	}
}
