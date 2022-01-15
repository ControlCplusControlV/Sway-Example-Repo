contract;

abi TestContract {
  fn sqrtu64(gas_: u64, amount_: u64, coin_: b256, amount: u64) -> u64;
  fn sqrtu32(gas_: u64, amount_: u64, coin_: b256, amount: u32) -> u32;
  fn sqrtu16(gas_: u64, amount_: u64, coin_: b256, amount: u16) -> u16;
  fn sqrtu8(gas_: u64, amount_: u64, coin_: b256, amount: u8) -> u8;

}

impl TestContract for Contract {
  fn sqrtu64(gas_: u64, amount_: u64, color_: b256, amount: u64) -> u64 {
    let value:u64 = amount % 10;

    value
  }
  fn sqrtu32(gas_: u64, amount_: u64, color_: b256, amount: u32) -> u32 {
    let value:u32 = amount % 10;

    value
  }
  fn sqrtu16(gas_: u64, amount_: u64, color_: b256, amount: u16) -> u16 {
    let value:u16 = amount % 10;

    value
  }
  fn sqrtu8(gas_: u64, amount_: u64, color_: b256, amount: u8) -> u8 {
    let value:u8 = amount % 10;

    value
  }
}
