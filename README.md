# RPCA BASED MOVING ENTITY DETECTION FROM A MOVING CAMERA

####
Robust Principal Component Analysis (RPCA) works well for detecting moving objects in a series of images taken from a stationary camera by separating the static background from the dynamic objects.  However, RPCA does not perform well at this task when the images were taken from a moving camera.  This paper investigates the accuracy of two different approaches for detecting moving objects in images taken from a moving camera.  The first approach is Tensor-RPCA, and performs reasonably well on short sequences of images. The second approach implements motion compensation techniques to generate the low rank and sparse matrix.
