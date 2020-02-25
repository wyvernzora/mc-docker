# mc-docker
This is a set of scripts and config files designed to generate docker images for running CurseForge minecraft servers.

## Generating an image
```
$ make <modpack>[:version]
$ make enigmatica-2-expert:1.50a
```
Make process will use latest version available if no version is specified

## Adding a modpack
1. Create a new directory under `modpacks/`
2. Create the JSON config file `modpacks/<modpack>/versions.json`
3. Add desired modpack versions along with server download URLs to the versions file
4. Add `modpacks/<modpack>/launch.sh` and include all the launch steps for the server
5. If there are custom build-time steps required after extracting the server archive, you can create `modpacks/<modpack>/setup.sh` and put all that logic in there. This file is only executed at docker build time!

## Launching a server
All important data for the server is symlink farmed into `/minecraft/data` volume, so to launch a server all you need to do is:
```
$ docker run -v /local/path/to/data:/minecraft/data -p 25565:25565 $USER/modpack:version
```
JVM memory allocation is WIP

## License
MIT
