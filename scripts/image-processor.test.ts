import { expect, test } from 'bun:test'
import { mkdtempSync, rmSync, symlinkSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join, resolve } from 'node:path'

test('compiled image processor loads native sharp outside the project cwd', () => {
  const directory = mkdtempSync(join(tmpdir(), 'image-processor-'))
  try {
    symlinkSync(resolve(import.meta.dir, '../node_modules'), join(directory, 'node_modules'))
    const entrypoint = join(directory, 'probe.ts')
    const binary = join(directory, 'probe')
    const modulePath = resolve(import.meta.dir, '../src/tools/FileReadTool/imageProcessor.ts')
    writeFileSync(entrypoint, `
      import { getImageProcessor, getImageCreator } from ${JSON.stringify(modulePath)}
      const create = await getImageCreator()
      const sharp = await getImageProcessor()
      const input = await create({ create: {
        width: 3000, height: 1000, channels: 3,
        background: { r: 255, g: 0, b: 0 },
      }}).png().toBuffer()
      const output = await sharp(input).resize(2000, 2000, {
        fit: 'inside', withoutEnlargement: true,
      }).png().toBuffer()
      const metadata = await sharp(output).metadata()
      if (metadata.width !== 2000 || metadata.height !== 667) {
        throw new Error(JSON.stringify(metadata))
      }
      console.log('image processing passed')
    `)
    const build = Bun.spawnSync([
      process.execPath, 'build', entrypoint, '--compile',
      '--compile-autoload-package-json', '--outfile', binary,
    ], { stdout: 'pipe', stderr: 'pipe' })
    expect(build.exitCode, build.stderr.toString()).toBe(0)
    const run = Bun.spawnSync([binary], {
      cwd: tmpdir(), stdout: 'pipe', stderr: 'pipe',
    })
    expect(run.exitCode, run.stderr.toString()).toBe(0)
    expect(run.stdout.toString()).toContain('image processing passed')
  } finally {
    rmSync(directory, { recursive: true, force: true })
  }
})
