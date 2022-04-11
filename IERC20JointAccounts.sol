// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * Interface for an ERC-20 token with joint accounts.
 */
interface IERC20JointAccounts is IERC20, IERC20Metadata {
    /**
     * @dev Emitted when `balanceHolder` shares balance access to `account`.
     */
    event BalanceAccessShared(address indexed balanceHolder, address indexed account);

    /**
     * @dev Emitted when `balanceHolder` revokes balance access from `account`.
     */
    event BalanceAccessRevoked(address indexed balanceHolder, address indexed account);

    /**
     * @dev Emitted when `account` updates its active balance holder to 
     * `activeBalanceHolder`.
     */
    event ActiveBalanceHolderUpdated(address indexed account, address indexed activeBalanceHolder);

    /**
     * @dev Shares `account` access to caller's balance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {BalanceAccessShared} event.
     *
     * Requirements:
     *
     * - `account` must not be caller.
     * - `account` must not currently have access to callers's balance.
     */
    function shareBalanceAccess(address account) external returns (bool);

    /**
     * @dev Revokes `account`'s access to caller's balance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {BalanceAccessRevoked} event.
     * May emit an {ActiveBalanceHolderUpdated} event.
     *
     * Requirements:
     *
     * - `account` must not be caller.
     * - `account` must currently have access to callers's balance.
     */
    function revokeBalanceAccess(address account) external returns (bool);

    /**
     * @dev Returns a boolean value indicating whether `account` has
     * access to `balanceHolder`'s balance.
     */
    function hasBalanceAccess(address account, address balanceHolder) external view returns (bool);

    /**
     * @dev Returns the active balance holder of `account`.
     */
    function activeBalanceHolderOf(address account) external view returns (address);

    /**
     * @dev Sets the active balance holder of the sender to `account`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an {ActiveBalanceHolderUpdated} event.
     *
     * Requirements:
     *
     * - Caller must currently have access to `account`'s balance.
     */
    function setActiveBalanceHolder(address account) external returns (bool);

    /**
     * @dev Balance of `account`. Directly uses addresses.
     */
    function addressBalanceOf(address account) external view returns (uint256);

    /**
     * @dev Allowance given to `spender` by `owner`. Directly uses addresses.
     */
    function addressAllowance(address owner, address spender) external view returns (uint256);
}
