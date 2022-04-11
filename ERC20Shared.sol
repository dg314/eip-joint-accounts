// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC20Shared.sol";

/**
 * ERC-20 token that allows groups of addresses to control the same 
 * token balance.
 */
contract ERC20Shared is IERC20Shared {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping (address => mapping(address => bool)) private _balanceAccess;
    mapping (address => address) private _activeBalanceHolders;

    uint256 private _totalSupply;

    /**
     * @dev Emitted when `account` requests membership in the group with ID
     * `id`.
     */
    event MembershipRequest(uint256 indexed id, address indexed account);

    /**
     * @dev Mints ERC-20 Shared with fixed `supply`.
     */
    constructor(uint256 supply) {
        _mint(msg.sender, supply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public pure override returns (string memory) {
        return "ERC-20 Shared";
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public pure override returns (string memory) {
        return "ERCS";
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Shares `account` access to caller's balance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {BalanceAccessShares} event.
     *
     * Requirements:
     *
     * - `account` must not be caller.
     * - `account` must not currently have access to callers's balance.
     */
    function shareBalanceAccess(address account) public override returns (bool) {
        require(msg.sender != account, "Account must not be caller");
        require(!_balanceAccess[account][msg.sender], "Account must not currently have access to caller's balance");

        _balanceAccess[account][msg.sender] = true;
        emit BalanceAccessShared(msg.sender, account);
        
        return true;
    }

    /**
     * @dev Revokes `account`'s access to caller's balance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {BalanceAccessRevoked} event.
     * May emit an {ActiveBalanceHolderUpdate} event.
     *
     * Requirements:
     *
     * - `account` must not be caller.
     * - `account` must currently have access to callers's balance.
     */
    function revokeBalanceAccess(address account) public override returns (bool) {
        require(msg.sender != account, "Account must not be caller");
        require(_balanceAccess[account][msg.sender], "Account must have access to caller's balance");

        _balanceAccess[account][msg.sender] = false;

        if (_activeBalanceHolders[account] == msg.sender) {
            _activeBalanceHolders[account] = account;
            emit ActiveBalanceHolderUpdated(account, account);
        }

        emit BalanceAccessRevoked(msg.sender, account);
        
        return true;
    }

    /**
     * @dev Returns a boolean value indicating whether `account` has
     * access to `balanceHolder`'s balance.
     */
    function hasBalanceAccess(address account, address balanceHolder) public view override returns (bool) {
        return (account == balanceHolder) ? true : _balanceAccess[account][balanceHolder];
    }

    /**
     * @dev Returns the active balance holder of `account`.
     */
    function activeBalanceHolderOf(address account) public view override returns (address) {
        address activeBalanceHolder = _activeBalanceHolders[account];

        return (activeBalanceHolder == address(0)) ? account : activeBalanceHolder;
    }

    /**
     * @dev Sets the active balance holder of the sender to `account`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an {ActiveBalanceHolderUpdate} event.
     *
     * Requirements:
     *
     * - Caller must currently have access to `account`'s balance.
     */
    function setActiveBalanceHolder(address account) public override returns (bool) {
        require(_balanceAccess[msg.sender][account], "Caller must have access to account's balance");

        _activeBalanceHolders[msg.sender] = account;
        emit ActiveBalanceHolderUpdated(msg.sender, account);

        return true;
    }

    /**
     * @dev Returns the active balance holder of the caller.
     */
    function _senderBalanceHolder() internal view returns (address) {
        return activeBalanceHolderOf(msg.sender);
    }

    /**
     * @dev See {IERC20-balanceOf}. Balance of `account`'s active balance holder.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[activeBalanceHolderOf(account)];
    }

    /**
     * @dev Balance of `account`. Directly uses addresses.
     */
    function addressBalanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}. Tranfers `amount` from the active balance
     * holder of the caller to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller's active balance holder must have a balance of at least
     * `amount`.
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(_senderBalanceHolder(), to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}. Allowance given to `spender` by `owner`'s
     * active balance holder.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[activeBalanceHolderOf(owner)][spender];
    }

    /**
     * @dev Allowance given to `spender` by `owner`. Directly uses addresses.
     */
    function addressAllowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_senderBalanceHolder(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _spendAllowance(from, _senderBalanceHolder(), amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address senderBalanceHolder = _senderBalanceHolder();
        _approve(senderBalanceHolder, spender, allowance(senderBalanceHolder, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address senderBalanceHolder = _senderBalanceHolder();
        uint256 currentAllowance = allowance(senderBalanceHolder, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(senderBalanceHolder, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}
