require "rubygems"
require "ai4r"
require "RMagick"

include Magick
#This app expects to be in a folder with image files whose names are just the solved text of the captcha
# You may need to  run:
# ls|sed 's/\(.*\).jpeg/mv & \1/'| sh
# in order to strip .jpeg from the end of filenames, or edit the code below. Have fun noobs!

puts "Examining a file to determine image dimensions and to process for validation post-training..."
image = Image::read("yelling").first;

#Black and Whitize the image
image = image.quantize(2, Magick::GRAYColorspace)
data_array = image.get_pixels(0,0,image.columns, image.rows)

#Quantisize data into binary/boolean matrix
data_array.collect!{|x| x.red==65535? 0:1 }

# Create the network with NUM_PIXELS inputs,
# and 26*7 outputs (max 7 chars in a VS captcha)
num_outputs = 184
net = Ai4r::NeuralNetwork::Backpropagation.new([image.columns * image.rows , num_outputs])

Dir.glob("*") {|filename|
  if !(filename.include? "csolve")
    puts "CAPTCHA: "+filename+", peforming image processing, please wait..."
    image = Image::read(filename).first;
    image = image.quantize(2, Magick::GRAYColorspace)
    data_array = image.get_pixels(0,0,image.columns, image.rows)
    data_array.collect!{|x| x.red==65535? 0:1 }
    # puts data_array
    # Perform training data padding
    output_array = Array.new(num_outputs, 0)
    for i in 0 .. 6 do
      if filename.length>i
        output_array[i*26+ filename[i]-97]=1
      end
    end
    puts "Training the network with this CAPTCHA, please wait"
    
    # Train the network
    net.train(data_array, output_array)
    puts "Done!"
  end
}

# Use it: Evaluate data with the trained network

puts "Post-training evaluation processing, please wait"
  output_array = Array.new(num_outputs, 0)
  
  output_array = net.eval(data_array)
 j=97
  for i in 0 .. output_array.length-1
    if output_array[i] > 0.01
      puts j.chr+" " +output_array[i].to_s
    end
    if j < 97+25
      j+=1
    else
      j=97
    end
  end

