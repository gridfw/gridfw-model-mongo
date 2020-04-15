const GulpGridfw= require('gulp-gridfw');
const Gulp= require('gulp');

// Compile
compiler= new GulpGridfw();
compiler.compileAndRunGulp(Gulp, 'gulp-file.coffee');
