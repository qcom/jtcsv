const gulp = require('gulp');
const plumber = require('gulp-plumber');
const notify = require('gulp-notify');
const sourcemaps = require('gulp-sourcemaps');
const coffee = require('gulp-coffee');

const paths = {
	coffee: ['./src/**/*.coffee']
};

function reportError(err) {
	notify({
		title: err.name,
		message: err.message,
	}).write(err);
	console.error(err.toString());
	this.emit('end');
}

// transpile es2015 -> es5
gulp.task('coffee', function() {
	return gulp.src(paths.coffee)
	.pipe(plumber({
		errorHandler: reportError
	}))
	.pipe(sourcemaps.init())
		.pipe(coffee({
			bare: true
		})
		.on('error', reportError))
	.pipe(sourcemaps.write('.'))
	.pipe(gulp.dest('dist'));
});

const allTasks = ['coffee'];

gulp.task('default', allTasks);

gulp.task('watch', allTasks, function() {
	gulp.watch(paths.coffee, ['coffee']);
});
