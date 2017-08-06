const assertThrow = require('./helpers/assertThrow')
var DAO = artifacts.require('DAO')
var MetaOrgan = artifacts.require('MetaOrgan')
var ConstitutionApp = artifacts.require('ConstitutionApp')
const { installOrgans, installApps } = require('./helpers/installer')

var Kernel = artifacts.require('Kernel')

const createDAO = () => DAO.new(Kernel.address)

contract('ConstitutionApp', accounts => {
  let dao, metadao, kernel, appOrgan, constitutionApp = {}

  beforeEach(async () => {
    dao = await createDAO()
    metadao = MetaOrgan.at(dao.address)
    kernel = Kernel.at(dao.address)

    await installOrgans(metadao, [MetaOrgan])
    await installApps(metadao, [ConstitutionApp])

    constitutionApp = ConstitutionApp.at(dao.address)
  })

  context('adding article', () => {
    beforeEach(async () => {
      await constitutionApp.addArticle('test summary 1', 'test reference 1')
    })

    it('added the article', async () => {
      assert.isOk(await constitutionApp.isValid(0), 'article should be considered valid')

      const [summary, reference, added, repealed] = await constitutionApp.getArticle(0)
      assert.equal(summary, 'test summary 1', 'summary should match')
      assert.equal(reference, 'test reference 1', 'reference should match')
      assert.isAbove(added, 0, 'addedOn should be above 0')
      assert.equal(repealed, 0, 'repealedOn should be 0')
    })

    it('repeal the article', async () => {
      await constitutionApp.repealArticle(0)
      assert.isNotOk(await constitutionApp.isValid(0), 'article should be invalid')
    })

    context('adding a second article', async () => {
      beforeEach(async () => {
        await constitutionApp.addArticle("test summary 2", "test reference 2")
      })

      it('added the new article', async () => {
        assert.isOk(await constitutionApp.isValid(1), 'article should be considered valid')

        const [summary, reference, added, repealed] = await constitutionApp.getArticle(1)
        assert.equal(summary, 'test summary 2', 'summary should match')
        assert.equal(reference, 'test reference 2', 'reference should match')
        assert.isAbove(added, 0, 'addedOn should be above 0')
        assert.equal(repealed, 0, 'repealedOn should be 0')      })

      it('repeal the new article', async () => {
        await constitutionApp.repealArticle(1)
        assert.isNotOk(await constitutionApp.isValid(1), 'article should be invalid')
      })
    })
  })
})
