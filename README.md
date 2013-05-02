This code recreates a bug with the bunny ruby gem.

Basically, there are two applications that talk to each other, test_poller1 and test_poller2.

Run both, then sit back and wait.  Eventually, the error below shows up and one or the other or both crash:

Unepxected exception in the main loop:
Bunny::UnexpectedFrame
Connection-level error: UNEXPECTED_FRAME - expected content header for class 60, got non content header frame instead
/Users/lovell/.rbenv/versions/1.9.3-p194/lib/ruby/gems/1.9.1/gems/bunny-0.9.0.pre10/lib/bunny/session.rb:354:in `handle_frame'
/Users/lovell/.rbenv/versions/1.9.3-p194/lib/ruby/gems/1.9.1/gems/bunny-0.9.0.pre10/lib/bunny/main_loop.rb:77:in `run_once'
/Users/lovell/.rbenv/versions/1.9.3-p194/lib/ruby/gems/1.9.1/gems/bunny-0.9.0.pre10/lib/bunny/main_loop.rb:32:in `block in run_loop'
/Users/lovell/.rbenv/versions/1.9.3-p194/lib/ruby/gems/1.9.1/gems/bunny-0.9.0.pre10/lib/bunny/main_loop.rb:29:in `loop'
/Users/lovell/.rbenv/versions/1.9.3-p194/lib/ruby/gems/1.9.1/gems/bunny-0.9.0.pre10/lib/bunny/main_loop.rb:29:in `run_loop'
Uncaught exception: caught an unexpected exception in the network loop: Connection-level error: UNEXPECTED_FRAME - expected content header for class 60, got non content header frame instead



