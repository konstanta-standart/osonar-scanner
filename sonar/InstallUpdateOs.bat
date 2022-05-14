@set LOGOS_CONFIG=logger.oscript.app.opm=ERROR;

@call opm install cmdline
@call opm install 1commands
@call opm install v8metadata-reader
@call opm install logos
@call opm install tempfiles
@call opm install stebi

@call opm update cmdline
@call opm update 1commands
@call opm update v8metadata-reader
@call opm update logos
@call opm update tempfiles
@call opm update stebi