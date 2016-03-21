Calculator Assignment 2 readme.txt

Note: All of the test cases included in the handout (and more) work on my calculator.

Design decisions:

	-I didn't like automatic enters for something like pi because they can make the stack content 	kind of weird. The only thing that automatically pushes onto the stack in this assignment is the 	"M" variable. Even so, if you want to evaluate (7+M), you would do it by saying:
		7,
		Return key,
		M,
		+
	
	-If you want to evaluate (3 + pi), you will do:
		pi,
		Return key,
		3,
		+
	-You can also reverse the pi and 3 order and get the same result.

Additional notes w/r/t Assignment spec compliance:

	I did not make any changes to the brain API from assignment 1.

	My calculator looks "good" on all iPhones, i.e., none of the buttons jump around--unless you 	flip the iPhone upside down. I'm trying to figure out how to avoid this. (The other option, which 
	is used by the built-in iOS calculator, is to not allow the calculator to orient if it is upside down,
	which I could not figure out how to implement in this version of Xcode / iOS / Swift).

	At first there were some behaviors that seemed strange to me, but I guess they actually make 	sense. E.g., when evaluating sqrt(3 + sqrt(5)) / 6, the description will show:

	3, Return, 5, Sqrt =>	3, sqrt(5)	(seems weird, but makes sense)
	+		       =>	(3 + sqrt(5))
	Sqrt, 6, /	       =>	(sqrt(3 + sqrt(5)) / 6 )


Thanks!

James	