%lang starknet
from starkware.cairo.common.math import assert_nn, assert_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.pow import pow
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc

@storage_var
func balance() -> (res: felt) {
}

@external
func increase_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: felt
) {
    with_attr error_message("Amount must be positive. Got: {amount}.") {
        assert_nn(amount);
    }

    let (res) = balance.read();
    balance.write(res + amount);
    return ();
}

@event
func output_printed(v: felt) {
}

@view
func get_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (res) = balance.read();
    return (res,);
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    //balance.write(0);
    return ();
}

@external
func invoke_advent{range_check_ptr, syscall_ptr: felt*}(index: felt) {
	if (index == 1) {
		puzzle_1();
	} else {
		if (index == 2) {
			puzzle_2();
		} else {
			if (index == 3) {
				puzzle_3();
			} else {
				tempvar range_check_ptr = range_check_ptr;
				tempvar syscall_ptr = syscall_ptr;
			}
		}
	}


	return ();
}

// it_* :: values that don't change with iteration (parameters from outside)
// elf_ix :: index of elf (increments on encountering 0)
func max_sum{range_check_ptr}(arr: felt*, arr_len: felt, elf_ix: felt, elf_sum: felt, max_ix: felt, max: felt) -> (v: felt, ix: felt) {
	alloc_locals;
	if (arr_len == 0) {
		return (max, max_ix);
	}

	if ([arr] == 0) {
		local max_ix2;
		local max2;
		let found_bigger = is_le(max, elf_sum);
		if (found_bigger == 1) {
			max_ix2 = elf_ix;
			max2 = elf_sum;
		} else {
			max_ix2 = max_ix;
			max2 = max;
		}

		return max_sum(
			arr + 1,
			arr_len - 1,
			elf_ix + 1,
			0,
			max_ix2,
			max2
		);

	} else {
		return max_sum(
			arr + 1,
			arr_len - 1,
			elf_ix,
			elf_sum + [arr],
			max_ix,
			max
		);
	}
}

func puzzle_1{range_check_ptr, syscall_ptr: felt*}() {
	alloc_locals;
	local input: (felt, felt, felt, felt, felt, felt, felt, felt, felt, felt, felt, felt, felt, felt ) = (
		1000, 2000, 3000, 0,
		4000, 0,
		5000, 6000, 0,
		7000, 8000, 9000, 0,
		10000,
		);

	let (__fp__, _) = get_fp_and_pc();
	let (max, max_ix) = max_sum(&input, 15, 0, 0, 0, 0);
	output_printed.emit(max);
	output_printed.emit(max_ix);

	return ();
}

// returns 1 or 0
func eq(a: felt, b: felt) -> felt {
	if (a == b) {
		return 1;
	} else {
		return 0;
	}
}

func normalize_bool(a: felt) -> felt {
	if (a == 0) {
		return 0;
	} else {
		return 1;
	}
}

func score_of_round(round_plan: felt*) -> felt {
	alloc_locals;
	let opponent = [round_plan];
	let me = [round_plan + 1];

	// don't need to normalize_bool
	local win = (
		eq(me, 10) * eq(opponent, 3)) + (
		eq(me, 20) * eq(opponent, 1)) + (
		eq(me, 30) * eq(opponent, 2));
	local draw = (
		eq(me, 10) * eq(opponent, 1)) + (
		eq(me, 20) * eq(opponent, 2)) + (
		eq(me, 30) * eq(opponent, 3));
	local lose = (
		eq(me, 10) * eq(opponent, 2)) + (
		eq(me, 20) * eq(opponent, 3)) + (
		eq(me, 30) * eq(opponent, 1));

	return (win * 6) + (draw * 3) + (lose * 0) + (me / 10);
}

func sum_score(round_plan: felt*, len: felt, sum: felt) -> felt {
	if (len == 0) {
		return sum;
	} else {
		return sum_score(
			round_plan + 2, 
			len - 2,
			sum + score_of_round(round_plan));
	}

}

// A = 1, X = 10  Rock
// B = 2, Y = 20  Paper
// C = 3, Z = 30  Scissors
//
// score = my selected + round result
// 0 - lose
// 3 - draw
// 6 - win
func puzzle_2{range_check_ptr, syscall_ptr: felt*}() {
	alloc_locals;
	tempvar input: felt* = new (1, 20, 2, 10, 3, 30);
	let score = sum_score(input, 6, 0);
	output_printed.emit(score);

	return ();
}


const B = 53;

// hint-based implementation which is not allowed to use on StarkNet so also didn't test

//// rucksack :: the big number whose digits represent items in the sack
//// i :: \in [0, cnt)
//// cnt :: number of items in the sack
//// known_same :: the number that appears twice
//// occ :: number of occurrences of known_same so far
//// returns number of occurrences
//func iter_content{range_check_ptr}(rucksack: felt, i: felt, cnt: felt, known_same: felt, occ: felt) -> felt {
//	alloc_locals;
//	if (i == cnt) {
//		assert occ = 2;
//		return (occ);
//	} else {
//		let (base) = pow(B, i);
//		let (above) = pow(B, i+1);
//		let (_, r) = unsigned_div_rem(rucksack, above);
//		let (v, _) = unsigned_div_rem(r, base);
//		local new_occ;
//		if (v == known_same) {
//			new_occ = occ + 1;
//		} else {
//			new_occ = occ;
//		}
//		return iter_content(rucksack, i+1, cnt, known_same, new_occ);
//	}
//}


// // returns sum of 'scores'
// func iter_rucksacks{range_check_ptr}(arr: felt*, len: felt) -> felt {
//	alloc_locals;
//	if (len == 0) {
//		return 0;
//	} else {
//		let rucksack = [arr];
//		let cnt = [arr + 1];
//		local same;
//		%{
//			B = 53 # must be same as the number below
//			left = set()
//			for i in range(ids.cnt):
//				base = B**i
//				above = B**(i+1)
//				v = int((ids.rucksack % above) / base)
//				if v in left:
//					ids.same = v
//					break
//				else:
//					left.add(v)
//		%}
//		iter_content(rucksack, 0, cnt, same, 0);
//		// the number in the rucksack is the same as score (let's assume)
//		return same + iter_rucksacks(
//			arr + 2,
//			len - 1);
//	}
//}

// exists :: array that keeps track of items found
// i :: \in [0, cnt)
// cnt :: number of items in the sack
// -> returns the number that occurrs twice (does not check that it's after half)
func iter_content{range_check_ptr}(exists: felt*, rucksack: felt, i: felt, cnt: felt) -> felt {
	alloc_locals;
	if (i == cnt) {
		assert 0 = 1; // error
		return (0);
	} else {
		let (above) = pow(B, i+1);
		let (_, r) = unsigned_div_rem(rucksack, above);
		local rr = r;
		let (base) = pow(B, i);
		let (v, _) = unsigned_div_rem(rr, base);

		if (exists[v] == 0) {
			assert exists[v] = 1;

			return iter_content(exists, rucksack, i + 1, cnt);

		} else {
			// found second item
			return (v);
		}
	}
}

func iter_rucksacks{range_check_ptr}(arr: felt*, len: felt, accum: felt) -> felt {
	alloc_locals;
	if (len == 0) {
		return (accum);
	} else {
		let (exists) = alloc();
		let score = iter_content(exists, [arr], 0, [arr + 1]);
		return iter_rucksacks(arr + 2, len - 1, accum + score);
	}
}

// N rucksacks
//	each 2 compartments, same number of items
//	find the letter that occurs both in left and right parts of the rucksacks
//	sum the priorities of these found letters (there is a priority mapping)
//
//	will represent each backpack as a felt
//	its content will be encoded as a base-52 number (52**0 * a0 + 52**1 * a1 + ...)
func puzzle_3{range_check_ptr, syscall_ptr: felt*}() {
	alloc_locals;
	tempvar input: felt* = new (
		1*B**0 + 2*B**1 + 3*B**2 + 2*B**3, 4,
		1*B**0 + 2*B**1 + 3*B**2 + 4*B**3 + 1*B**4 + 6*B**5 + 7*B**6 + 8*B**7, 8,
		1*B**0 + 2*B**1 + 3*B**2 + 4*B**3 + 5*B**4 + 2*B**5 + 7*B**6 + 8*B**7, 8,
	);

	let score = iter_rucksacks(input, 3, 0);
	// expect: 2 + 1 + 2
	output_printed.emit(score);

	return ();
}
