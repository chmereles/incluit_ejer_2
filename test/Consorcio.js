const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Consorcio contract", function () {

  let Consorcio;
  let consorcio;
  let consorcioBalance;
  let admin;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [admin, addr1, addr1] = await ethers.getSigners();

    Consorcio = await ethers.getContractFactory("Consorcio");
    consorcio = await Consorcio.deploy();
    consorcioBalance = await Consorcio.deploy({ value: ethers.utils.parseEther("1.0") });
  });

  describe("constructor", async function () {
    it("deberia inicializar las clases bases", async function () {
    })
  });

  describe("payExpenses", function () {

    it("debería revertir la transaccion, cuando el usuario que quiere pagar no esta cargado", async function () {
      await expect(consorcio.connect(addr1).payExpenses())
        .to.be.revertedWith('Consorcio: El usuario no puede realizar pagos');
    });

    it("deberia permitir el pago y validar la transaccion, con un usuario cargado", async function () {
      await consorcio.addPayerUser(addr1.address, 'User payer');
      await expect(consorcio.connect(addr1).payExpenses({value: 1}))
        .to.changeEtherBalance(consorcio, 1);
    });
  });

  describe("addPayerUser", function () {
    it("deberia revertir la tranasaccion, si el usuario no es admin", async function () {
      await expect(consorcio.connect(addr1).addPayerUser(addr1.address, "User payer"))
        .to.be.revertedWith("Ownable: caller is not the owner");
    });
  })

  describe("payEmployee", function () {
    let Empleado;
    let empleado;

    beforeEach(async function () {
      Empleado = await ethers.getContractFactory("Employee");
      empleado = await Empleado.deploy("User employee");
    });

    it("deberia pagar a un empleado y el balance del empleado incrementarse en el valor pagado", async function () {
      await consorcioBalance.addEmployeeUser(empleado.address);
      await expect(consorcioBalance.payEmployee(0, 1))
        .to.changeEtherBalances(
          [consorcioBalance, empleado],
          [-1, 1]
        );
    });

    it("deberia revertir la transaccion si el empleado no esta cargado", async function () {
      await consorcioBalance.addEmployeeUser(empleado.address);
      await expect(consorcioBalance.payEmployee(1, 2))
        .to.be.revertedWith("Consorcio: El empleado no existe");
    });
  })

  describe("payService", function () {
    it("deberia pagar a un servicio", async function () {
      let serviceIndex = 0;
      let service = await consorcioBalance.getService(serviceIndex);

      await expect(consorcioBalance.payService(serviceIndex, 1))
        .to.changeEtherBalances(
          [consorcioBalance, service],
          [-1, 1]
        );
    });
  })

  describe("specificPayment", function () {
    it("pagar cosas puntuales", async function () {
      await expect(consorcioBalance.specificPayment(addr1.address, 1))
        .to.changeEtherBalances([consorcioBalance, addr1], [-1, 1]);
    })
  });
});