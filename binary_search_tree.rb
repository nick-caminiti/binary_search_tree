module Comparable
  ##
end

class Node
  attr_reader :data
  attr_accessor :left, :right

  def initialize(data, left = nil, right = nil)
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

  def insert(value)
    current_node = @root
    until current_node.left.nil? && current_node.right.nil? 
      return if value == current_node.data

      current_node = if value < current_node.data
                       current_node.left
                     else
                       current_node.right
                     end

      if current_node.left.nil? && value < current_node.data
        current_node.left = Node.new(value) 
        return
      elsif current_node.right.nil? && value > current_node.data
        current_node.right = Node.new(value) 
        return
      end
    end
  end

  def delete(value)
    current_node = @root
    parent_node = nil
    present = false
    until present
      present = true if value == current_node.data
      if value < current_node.data
        break if current_node.left.nil?
        parent_node = current_node
        current_node = current_node.left   
      elsif value > current_node.data
        break if current_node.right.nil?
        parent_node = current_node
        current_node = current_node.right
      end
    end
    remove_node(current_node, parent_node) if present
  end

  def remove_node(current_node, parent_node)
    if current_node.left.nil? && current_node.right.nil?
      if current_node.data < parent_node.data
        parent_node.left = nil
      else
        parent_node.right = nil
      end
    elsif current_node.left.nil? || current_node.right.nil?
      if current_node.left.nil?
        current_node.data < parent_node.data ? parent_node.left = current_node.right : parent_node.right = current_node.right
      else
        current_node.data < parent_node.data ? parent_node.left = current_node.left : parent_node.right = current_node.left
      end
    else
      replace_node_parent = current_node
      replace_node = current_node.right
      until replace_node.left.nil?
        replace_node_parent = replace_node
        replace_node = replace_node.left
      end

      remove_node(replace_node, replace_node_parent)

      if parent_node.nil?
        @root = replace_node
      elsif current_node.data < parent_node.data 
        parent_node.left = replace_node
      else
        parent_node.right = replace_node
      end
      replace_node.left = current_node.left
      replace_node.right = current_node.right
    end
  end

  def find(value)
    current_node = @root
    present = false
    until present
      present = true if value == current_node.data
      if value < current_node.data
        break if current_node.left.nil?

        current_node = current_node.left
      elsif value > current_node.data
        break if current_node.right.nil?

        current_node = current_node.right
      end
    end
    current_node if present
  end

  def level_order
    queue = []
    return_array = []
    queue[0] = @root

    until queue.empty?
      current_node = queue[0]
      queue.shift
      queue.push(current_node.left) unless current_node.left.nil?
      queue.push(current_node.right) unless current_node.right.nil?
      if block_given?
        yield current_node
      else
        return_array.push(current_node.data)
      end
    end
    return_array unless block_given?
  end

  def level_order_recur(queue = [@root],return_array = [], &block)
    if queue.empty?
      return return_array unless block_given?

      return
    end
    current_node = queue[0]
    queue.shift
    queue.push(current_node.left) unless current_node.left.nil?
    queue.push(current_node.right) unless current_node.right.nil?
    if block_given?
      yield current_node
    else
      return_array.push(current_node.data)
    end
    level_order_recur(queue, return_array, &block)    
  end

  def preorder(return_array = [], root = @root, &block)
    if block_given?
      yield root
    else
      return_array.push(root.data)
    end
    preorder(return_array, root.left, &block) unless root.left.nil?
    preorder(return_array, root.right, &block) unless root.right.nil?
    return_array
  end

  def inorder(return_array = [], root = @root, &block)
    inorder(return_array, root.left, &block) unless root.left.nil?
    if block_given?
      yield root
    else
      return_array.push(root.data)
    end
    inorder(return_array, root.right, &block) unless root.right.nil?
    return_array
  end

  def postorder(return_array = [], root = @root, &block)
    postorder(return_array, root.left, &block) unless root.left.nil?
    postorder(return_array, root.right, &block) unless root.right.nil?
    if block_given?
      yield root
    else
      return_array.push(root.data)
    end
    return_array
  end

  def height(node, height = 0)
    return height if node.left.nil? && node.right.nil?

    height += 1

    left_height = if node.left.nil?
                    0
                  else
                    height(node.left, height)
                  end

    right_height = if node.right.nil?
                     0
                   else
                     height(node.right, height)
                   end
    left_height > right_height ? left_height : right_height
  end

  def depth(node)
    return nil if node.nil?

    current_node = @root
    depth = 0
    until current_node == node || (current_node.left.nil? && current_node.right.nil?)
      depth += 1
      current_node = node.data < current_node.data ? current_node.left : current_node.right
    end
    depth
  end

  def balanced?
    (height(@root.left) - height(@root.right)).abs <= 1
  end

  def rebalance
    new_array = []
    self.inorder do |node|
      new_array << node.data
    end
    @root = build_tree(new_array)
  end
end

# array = [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]
# # [1, 3, 4, 5, 7, 8, 9, 23, 67, 324, 6345]
# p array.uniq.sort
# tree = Tree.new(array)
# # p tree
# tree.pretty_print
# tree.insert(2)
# tree.insert(320)
# tree.insert(323)
# tree.insert(321)
# tree.insert(320)
# tree.insert(319)
# # tree.insert(319)
# tree.insert(315)
# tree.insert(316)
# tree.insert(24)
# # tree.pretty_print
# tree.insert(9)
# tree.insert(30)
# # tree.insert()
# tree.insert(6)
# tree.pretty_print
# tree.delete(324)
# tree.pretty_print
# # puts tree.find(67)
# # tree.level_order_recur { |node| puts node.data }
# # p tree.level_order_recur
# # tree.preorder { |node| puts node.data }
# # p tree.preorder
# # p tree.height(tree.find(320))
# # p tree.depth(tree.find(6))
# p tree.balanced?
# tree.rebalance
# tree.pretty_print
# p tree.balanced?

test_array = (Array.new(15) {rand(1..100) })
test_tree = Tree.new(test_array)
test_tree.pretty_print
puts test_tree.balanced?

# test_tree.level_order { |node| puts node.data }
# test_tree.preorder { |node| puts node.data }
# test_tree.inorder { |node| puts node.data }
# test_tree.postorder { |node| puts node.data }

test_tree.insert(101)
test_tree.insert(102)
test_tree.insert(103)
test_tree.insert(104)
test_tree.insert(105)

test_tree.pretty_print
puts test_tree.balanced?

test_tree.rebalance

test_tree.pretty_print
puts test_tree.balanced?

# test_tree.level_order { |node| puts node.data }
# test_tree.preorder { |node| puts node.data }
test_tree.inorder { |node| puts node.data }
# test_tree.postorder { |node| puts node.data }