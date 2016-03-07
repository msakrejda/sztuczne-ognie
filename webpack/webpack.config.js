'use strict'

let path = require('path')
let webpack = require('webpack')

let debug = process.env.DEBUG == 'true'

console.log(`DEBUG: ${debug}`)

let config = {
  target: 'web',

  debug: debug,
  bail: true,
  profile: !debug,

  entry: [
    'eventsource-polyfill',
    './client-assets/main.js'
  ],

  devtool: debug ? 'eval-source-map' : '#source-map',

  output: {
    path: path.resolve('static/dist'),
    pathinfo: debug,
    publicPath: '/static/',
    filename: 'bundle.js',
  },

  module: {
    loaders: [
      {
        test: /\.scss$/,
        loader: 'style!css!autoprefixer?browsers=last 2 version!sass?outputStyle=expanded'
      }, {
        test: /\.jsx?$/,
        loader: 'babel',
        include: [path.resolve('./src/')],
      }
    ],
    noParse: /\.min\.js/,
  },

  resolve: {
    root: path.resolve('./client-assets'),
    extensions: ['', '.js', '.scss'],
  },
}

if (!debug) {
  config.plugins = [
    new webpack.optimize.OccurenceOrderPlugin(true),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin({ output: {comments: false} })
  ]
}

module.exports = config
