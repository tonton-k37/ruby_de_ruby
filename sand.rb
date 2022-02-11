# frozen_string_literal: true

leaf_a = ['leaf a']
leaf_b = ['leaf b']
leaf_c = ['leaf c']
leaf_d = ['leaf d']

node2 = ['fushi 2', leaf_a, leaf_b]

node3 = ['fushi 3', leaf_c, leaf_d]

node1 = ['fushi 1', node2, node3]

#
# node1
# node2 node3
# leaf_a leaf_b, leaf_c leaf_d
#

def preorder(tree)
  tree.each { |branch| branch.respond_to?(:each) ? preorder(branch) : p(branch) }
end

preorder(node1)

def reversive(tree)
  tree.reverse.each { |branch| branch.respond_to?(:each) ? reversive(branch) : p(branch) }
end

reversive(node1)
