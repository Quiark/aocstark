%lang starknet
from src.main import score_of_round, sum_score
from starkware.cairo.common.cairo_builtins import HashBuiltin

@contract_interface
namespace AdventContract {
    func invoke_advent(index: felt) {
    }
}

func deploy() -> felt {
    alloc_locals;

    local contract_address: felt;
    // We deploy contract and put its address into a local variable. Second argument is calldata array
    %{ ids.contract_address = deploy_contract("./src/main.cairo", []).contract_address %}
	return contract_address;
}

@external
func test_puzzle_1{syscall_ptr: felt*, range_check_ptr}() {
	let addr = deploy();

	AdventContract.invoke_advent(contract_address=addr, index=1);
    return ();
}

@external
func test_puzzle_2{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
	let addr = deploy();

	AdventContract.invoke_advent(contract_address=addr, index=2);
    return ();
}

@external
func test_puzzle_2_sum() {
	tempvar input: felt* = new (1, 20);
	let sum = score_of_round(input);
	assert sum = 8;

	tempvar input: felt* = new (1, 20, 2, 10, 3, 30);
	let score = sum_score(input, 6, 0);
	assert score = 15;

	assert 2**5 = 32;

	return ();
}

@external
func test_puzzle_3{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
	let addr = deploy();

	AdventContract.invoke_advent(contract_address=addr, index=3);
    return ();
}
