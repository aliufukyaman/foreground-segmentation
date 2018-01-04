
------------------------------
-- library
------------------------------

require 'torch'
require 'nn'
require 'cunn'
require 'cudnn'

------------------------------
-- function
------------------------------

function branch(insert)

	local block = nn.Sequential()
	local max_pooling = nn.SpatialMaxPooling(2,2,2,2)
	block:add(max_pooling)
	block:add(insert)
	-- block:add(nn.SpatialMaxUnpooling(max_pooling))
	block:add(nn.SpatialUpSamplingNearest(2))

	local parallel = nn.ConcatTable(2)
	parallel:add(nn.Identity())
	parallel:add(block)

	local model = nn.Sequential()
	model:add(parallel)
	model:add(nn.JoinTable(2))

	return model
end

function conv(n_input, n_middle, n_output, filtsize, out_bn)

	local model = nn.Sequential()

	model:add(cudnn.SpatialConvolution(n_input, n_middle, filtsize, filtsize, 1, 1, 1, 1))
	model:add(nn.SpatialBatchNormalization(n_middle))
	model:add(nn.LeakyReLU(0.1, true))

	model:add(cudnn.SpatialConvolution(n_middle, n_output, filtsize, filtsize, 1, 1, 1, 1))
	if out_bn == true then
		model:add(nn.SpatialBatchNormalization(n_output))
	end

	return model

end

function newmodel()

	-- number of output
	local num_output = num_class or 1

	-- filter size
	local filtsize = 3

	local block0 = conv(512, 1024, 512, filtsize, true)

	local block1 = nn.Sequential()
	block1:add(conv(256, 512, 512, filtsize, true))
	block1:add(branch(block0))
	block1:add(conv(512*2, 512, 256, filtsize, true))

	local block2 = nn.Sequential()
	block2:add(conv(128, 256, 256, filtsize, true))
	block2:add(branch(block1))
	block2:add(conv(256*2, 256, 128, filtsize, true))

	local block3 = nn.Sequential()
	block3:add(conv(64, 128, 128, filtsize, true))
	block3:add(branch(block2))
	block3:add(conv(128*2, 128, 64, filtsize, true))

	local model = nn.Sequential()
	model:add(conv(3, 64, 64, filtsize, true))
	model:add(branch(block3))
	model:add(conv(64*2, 64, num_output, filtsize, false))

	model:add(nn.Sigmoid())

	return model
end

--[[
 <<References>>
  [1] U-Net: Convolutional Networks for Biomedical Image Segmentation
 	Olaf Ronneberger, Philipp Fischer, Thomas Brox
 	https://arxiv.org/abs/1505.04597
--]]
