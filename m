Date: Tue, 13 Jun 2000 20:51:58 -0300
Subject: kswapd eating too much CPU on ac16/ac18
Message-ID: <20000613205158.A9782@cesarb.personal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've seen this behavior both in ac16 and in ac18. ac4 worked fine (and was the
fastest kernel I've ever seen on that box)

The box is a 386SX25, with 8MB RAM. The problem is that kswapd eats 99.0% of
the CPU while running dpkg (I also made it happen with X). dpkg uses 10MB of
memory in a particulary awful access pattern (so it swaps a lot).

ac4 was faster than ever, it looked like it wasn't swapping at all

ac16 and ac18 are both awful, dpkg takes an infinite time, all of it dominated
by kswapd (running top -s and vmstat 1 at the same time). When the problem
happens everything seems to hang (vmstat lumps some seconds into one, as I can
see in the interrupt count), no disk activity happens (as if it was lost
thinking what to do next), and on the next update I can see kswapd ate an awful
amount of CPU (ok, top eats 20% CPU on that box, but why would ac4 remain
pretty responsive when ac16/ac18 stop to a halt?)

It's not zone related (only 8Mb of memory)

To reproduce: use mem=8M (or use a box like mine ;) ) and run dpkg --list (or
even better, try to install something using dpkg)

I think new VM ideas should always be tested with mem=8M and a dpkg run...

-- 
Cesar Eduardo Barros
cesarb@nitnet.com.br
cesarb@dcc.ufrj.br
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
