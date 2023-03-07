module Comparable
  ##
end

class Node
  attr_reader :data
  attr_accessor :left, :right

  def initialize(data, left, right)
    @data = data
    @left = left
    @right = right
  end
end

class Tree
  def initialize(array)
    @array = array
    @root = build_tree(array)
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def build_tree(array)
    array = array.uniq.sort
    mid = array.length / 2
    case array.length
    when 1
      Node.new(array[0], nil, nil)
    when 2
      Node.new(array[0], nil, Node.new(array[1], nil, nil))
    else
      left = build_tree(array[0, mid])
      right = build_tree(array[mid + 1, array.length - 1])
      Node.new(array[mid], left, right)
    end
  end
end

array = [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]
# [1, 3, 4, 5, 7, 8, 9, 23, 67, 324, 6345]
p array.uniq.sort
tree = Tree.new(array)
p tree
tree.pretty_print