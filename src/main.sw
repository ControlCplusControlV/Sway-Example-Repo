contract;

// Needed for Hash Mappings
use std::chain::*;
use std::hash::*;
use std::storage::*;

/* --------------- Rebase Handling --------------- */

pub struct Rebase {
    elastic:u64,
    base:u64,
}

fn to_base(total:Rebase, elastic:u64, roundUp:bool) -> u64 {
    let mut base:u64 = 0;

    if(total.elastic == 0){
        base = elastic;
    } else {
        base = (elastic * total.base) / total.elastic;
        if (roundUp && (base * total.elastic) / total.base < elastic) {
            base = base + 1;
        };
    }; 

    base
}


fn to_elastic(total:Rebase, base:u64, roundUp:bool) -> u64 {
    let mut elastic:u64 = 0;

    if(total.elastic == 0){
        elastic = base;
    } else {
        elastic = (base * total.elastic) / total.base;
        
        if (roundUp && (elastic * total.base) / total.elastic < base) {
            elastic = elastic + 1;
        };
    };

    elastic
}

fn add(total:Rebase, elastic:u64, base:u64) -> Rebase {
    total.elastic = total.elastic + elastic;
    total.base = total.base + base;

    total
}

fn sub(total:Rebase, elastic:u64, base:u64) -> Rebase {
    total.elastic = total.elastic - elastic;
    total.base = total.base - base;

    total
}

/* ---------------- Important to note that these methods are different than Boring Solidity ----------- */
// Storage is iffy so this just returns a new rebase every time, Functional Programming remains supreme

fn add_elastic(total:Rebase, elastic:u64) -> Rebase {
    total.elastic = total.elastic + elastic;

    total
}

fn sub_elastic(total:Rebase, elastic:u64) -> Rebase {
    total.elastic = total.elastic - elastic;

    total
}

/* ---------------- Mapping Functions ----------------------- */

pub trait PairMapping {
	fn store(self, key1:b256, key2: b256, value:u64);
	fn retrieve(self, key1:b256, key2: b256) -> u64;
}

pub trait BalanceMapping {
	fn store_bal(self, key1:b256, value:Rebase);
	fn retrieve_bal(self, key1:b256) -> Rebase;
}

// Key (b256, b256) which is address -> (address -> u64)

pub struct BytesMapping{
	map_id : b256
}

impl PairMapping for BytesMapping {
    fn store(self, key1:b256, key2: b256, value:u64) {
        let storage_slot = hash_pair(key1, key2, HashMethod::Sha256);

        store(storage_slot, value);

    }

    fn retrieve(self, key1: b256, key2: b256) -> u64 {
        let storage_slot = hash_pair(key1, key2, HashMethod::Sha256);


        let resultingValue = get::<u64>(storage_slot);



        resultingValue
    }
}

impl BalanceMapping for BytesMapping {

    fn store_bal(self, key1:b256, value:Rebase) {
        let storage_slot = hash_pair(key1, self.map_id, HashMethod::Sha256);
        // Cursed way to store a struct, I am converting the storage slot to a uint
        // incrementing it, then casting back to a byte array
        let mut slotNumber:b256 = storage_slot;
        let mut storage_slot2:b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        let shiftvalue:u64 = 1;
        storage_slot2 = asm(s1: slotNumber,s2:storage_slot2, s3:shiftvalue) {
            sll s2 s1 s3;
            
            s2:b256
        };

        store(storage_slot, value.elastic);
        store(storage_slot2, value.base);

    }

    fn retrieve_bal(self, key1:b256) -> Rebase {
        let storage_slot = hash_pair(key1, self.map_id, HashMethod::Sha256);
        // Cursed way to store a struct, I am converting the storage slot to a uint
        // incrementing it, then casting back to a byte array
        let mut slotNumber:b256 = storage_slot;
        let mut storage_slot2:b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        let shiftvalue:u64 = 1;
        storage_slot2 = asm(s1: slotNumber,s2:storage_slot2, s3:shiftvalue) {
            sll s2 s1 s3;
            
            s2:b256
        };



        let resultingElastic = get::<u64>(storage_slot);
        let resultingBase = get::<u64>(storage_slot2);

        let resultingValue:Rebase = Rebase{
            elastic: resultingElastic,
            base: resultingBase,
        };    


        resultingValue
    }
}

abi CopiedSwayTest {
    fn test_store(gas_: u64, amount_: u64, color_: b256, input: u64);
    fn test_retrieve(gas_: u64, amount_: u64, color_: b256, input: u64) -> u64;
    fn test_rebase_map_store(gas_: u64, amount_: u64, color_: b256, input: u64);
    fn test_rebase_map_retrieve(gas_: u64, amount_: u64, color_: b256, input: u64) -> u64;

}

impl CopiedSwayTest for Contract {
    fn test_store(gas_: u64, amount_: u64, color_: b256, input: u64) {
        let myMapping = BytesMapping{
            map_id: 0x0000000000000000000000000000000000000000000000000000000000000000,
        };

        let key1:b256 = 0x0000000000000000000500000000000000000000000000000000000000000000;
        let key2:b256 = 0x0000000000000000000000000000000000600000000000000000000000000000;

        myMapping.store(key1, key2, input);
    }

    fn test_retrieve(gas_: u64, amount_: u64, color_: b256, input: u64) -> u64{
        let myMapping = BytesMapping{
            map_id: 0x0000000000000000000000000000000000000000000000000000000000000000,
        };

        let key1:b256 = 0x0000000000000000000500000000000000000000000000000000000000000000;
        let key2:b256 = 0x0000000000000000000000000000000000600000000000000000000000000000;

        let stored_num:u64 = myMapping.retrieve(key1, key2);

        stored_num
    }

    fn test_rebase_map_store(gas_: u64, amount_: u64, color_: b256, input: u64) {
        let myMapping = BytesMapping{
            map_id: 0x0000000000000004000000400000000000000040000000000400004000000000,
        };   

        let key1:b256 = 0x0000000000000000000000010000010000000000001000000100000000000000;

        let test_base:Rebase = Rebase{
            base: 10,
            elastic: 100,
        };

        myMapping.store_bal(key1, test_base);
    }

    fn test_rebase_map_retrieve(gas_: u64, amount_: u64, color_: b256, input: u64) -> u64 {
        let myMapping = BytesMapping{
            map_id: 0x0000000000000004000000400000000000000040000000000400004000000000,
        };   

        let key1:b256 = 0x0000000000000000000000010000010000000000001000000100000000000000;

        let returnVal:Rebase = myMapping.retrieve_bal(key1);

        let returnNum:u64 = returnVal.elastic + returnVal.base;

        returnNum 
    }
}
