const assertThrow = require('./helpers/assertThrow')
var DAO = artifacts.require('DAO')
var MetaOrgan = artifacts.require('MetaOrgan')
var CodeOfLawApp = artifacts.require('CodeOfLawApp')
const { installOrgans, installApps } = require('./helpers/installer')

var Kernel = artifacts.require('Kernel')

const createDAO = () => DAO.new(Kernel.address)

contract('CodeOfLawApp', accounts => {
  let dao, metadao, kernel, appOrgan, codeOfLawApp = {}

  beforeEach(async () => {
    dao = await createDAO()
    metadao = MetaOrgan.at(dao.address)
    kernel = Kernel.at(dao.address)

    await installOrgans(metadao, [MetaOrgan])
    await installApps(metadao, [CodeOfLawApp])

    codeOfLawApp = CodeOfLawApp.at(dao.address)
  })

  context('adding law', () => {
    beforeEach(async () => {
      await codeOfLawApp.addLaw('test summary 1', 'test reference 1')
    })

    it('added the law', async () => {
      assert.isOk(await codeOfLawApp.isValidLaw(0), 'law should be considered valid')

      const [summary, reference, added, repealed] = await codeOfLawApp.getLaw(0)
      assert.equal(summary, 'test summary 1', 'summary should match')
      assert.equal(reference, 'test reference 1', 'reference should match')
      assert.isAbove(added, 0, 'addedOn should be above 0')
      assert.equal(repealed, 0, 'repealedOn should be 0')
    })

    it('repeal the law', async () => {
      await codeOfLawApp.repealLaw(0)
      assert.isNotOk(await codeOfLawApp.isValidLaw(0), 'law should be invalid')
    })

    context('adding a second law', async () => {
      beforeEach(async () => {
        await codeOfLawApp.addLaw("test summary 2", "test reference 2")
      })

      it('added the new law', async () => {
        assert.isOk(await codeOfLawApp.isValidLaw(1), 'law should be considered valid')

        const [summary, reference, added, repealed] = await codeOfLawApp.getLaw(1)
        assert.equal(summary, 'test summary 2', 'summary should match')
        assert.equal(reference, 'test reference 2', 'reference should match')
        assert.isAbove(added, 0, 'addedOn should be above 0')
        assert.equal(repealed, 0, 'repealedOn should be 0')      })

      it('repeal the new law', async () => {
        await codeOfLawApp.repealLaw(1)
        assert.isNotOk(await codeOfLawApp.isValidLaw(1), 'law should be invalid')
      })
    })
  })
})
