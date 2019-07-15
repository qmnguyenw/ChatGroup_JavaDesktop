#------Create new simulator object-------
set ns [ new Simulator]
#------Turn on a tracefile------
#open file for nam tracing
set namf [open init.nam w]
$ns namtrace-all $namf
#open file for ns tracing
set tracef [open init.tr w]
$ns trace-all $tracef

set proto rlm
$ns color 1 red
$ns color 2 blue
$ns color 3 green
#------Create hosts------
set client1 [$ns node]
set client2 [$ns node]
set client3 [$ns node]
set router [$ns node]
set server [$ns node]
#------Create link------
                        
$ns duplex-link $client1 $router  2.5Mb 50ms DropTail
$ns duplex-link $client2 $router  2.5Mb 50ms DropTail
$ns duplex-link $client3 $router  2.5Mb 50ms DropTail
$ns duplex-link $router  $server  400Kb 50ms DropTail

$ns queue-limit $router $server 20

$ns duplex-link-op $router $server queuePos 0.5
                  
$ns duplex-link-op $client1 $router orient down-right
$ns duplex-link-op $client2 $router orient right 
$ns duplex-link-op $client3 $router orient up-right
$ns duplex-link-op $router $server orient right


#------Labeling------
$ns at 0.0 "$client1 label Client1"
$ns at 0.0 "$client2 label Client2"
$ns at 0.0 "$client3 label Client3"
$ns at 0.0 "$router label Router"
$ns at 0.0 "$server label Server"

$router shape box
$server shape hexagon
#------Client 1------
set tcp1 [new Agent/TCP]
$tcp1 set maxcwnd_ 15
$tcp1 set packetSize_ 960
$tcp1 set fid_ 1
$tcp1 set window_ 100
$ns attach-agent $client1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $server $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns add-agent-trace $tcp1 tcp
$tcp1 attach $tracef
$tcp1 tracevar ack_
$ns at 1.0 "$ftp1 start"
$ns at 15.0 "$ftp1 stop"
#------Client2------
set tcp2 [new Agent/TCP]
$tcp2 set fid_ 2
$tcp2 set packetSize_ 960
$tcp2 set maxcwnd_ 15
$tcp2 set window_ 100
$ns attach-agent $client2 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $server $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns add-agent-trace $tcp2 tcp2
$tcp2 tracevar cwnd_
$ns at 1.0 "$ftp2 start"
$ns at 15.0 "$ftp2 stop"
#------Client3------
 set tcp3 [new Agent/TCP]
$tcp3 set fid_ 3
$tcp3 set maxcwnd_ 15
$tcp3 set packetsize_ 960
$tcp3 set window_ 100
$ns attach-agent $client3 $tcp3
set sink3 [new Agent/TCPSink]
$ns attach-agent $server $sink3
$ns connect $tcp3 $sink3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ns add-agent-trace $tcp3 tcp3
$tcp3 tracevar ack_
$ns at 1.0 "$ftp3 start"
$ns at 15.0 "$ftp3 stop"


#define procedure to plot the congestion window
proc xgACK {tcpSource outfile} {
   	global ns
   	set now [$ns now]
   	set tracevar [$tcpSource set cwnd_]
	# the data is recorded in a xg file
   	puts  $outfile  "$now $tracevar"
   	$ns at [expr $now+0.1] "xgACK $tcpSource  $outfile"
}

set outfile [open  "graph.xg"  w]
$ns  at  0.0  "xgACK $tcp1  $outfile"

proc xgACK1 {tcpSource outfile} {
   	global ns
   	set now [$ns now]
   	set tracevar [$tcpSource set ack_]
	# the data is recorded in a xg file
   	puts  $outfile  "$now $tracevar"
   	$ns at [expr $now+0.1] "xgACK $tcpSource  $outfile"
}

#define finish procedure 
proc finish {} {
	global ns namf tracef xgraph
	$ns flush-trace
	close $namf
	#exec xgraph graph.xg -geometry 800x400
	exit 0
 	}
#schedule finish proc
$ns at 20.5 "finish"
$ns run