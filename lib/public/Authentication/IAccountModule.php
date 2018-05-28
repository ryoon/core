<?php

namespace OCP\Authentication;

use OC\Authentication\Exceptions\AccountCheckException;
use OCP\IUser;

/**
 * Interface IAccountModule
 *
 * @package OCP\Authentication
 * @since 10.0.9
 */
interface IAccountModule {

	/**
	 * The check is called on every request, so it should be cheap, eg an
	 * app or per user config. If the check is mor complex try decoupling it
	 * from every request by registering an event listener and setting a user
	 * config.
	 *
	 * @since 10.0.9
	 *
	 * @param IUser $user
	 * @throws AccountCheckException
	 */
	public function check(IUser $user);
}
