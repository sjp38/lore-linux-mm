Message-ID: <3D948EA6.A6EFC26B@austin.ibm.com>
Date: Fri, 27 Sep 2002 12:00:22 -0500
From: Bill Hartner <hartner@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: VolanoMark Benchmark results for 2.5.26, 2.5.26 + rmap, 2.5.35,and  
 2.5.35 + mm1
References: <Pine.LNX.4.44L.0209172219200.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> 
> > > 2.5.26 vs 2.5.26 + rmap patch
> > > -----------------------------
> > > It appears as though the page stealing decisions made when using the
> > > 2.5.26 rmap patch may not be as good as the baseline for this workload.
> > > There was more swap activity and idle time.
> >
> > Do you have similar results for 2.4 and 2.4-rmap?
> 
> If Bill is going to test this, I'd appreciate it if he could use
> rmap14a (or newer, if I've released it by the time he gets around
> to testing).
> 

More VolanoMark results using an 8-way 700 Mhz under memory pressure for
2.4.19 and rmap14b.

Details of SUT same as :

http://marc.theaimsgroup.com/?l=linux-mm&m=103229747000714&w=2

NOTE : the swap device is on ServeRAID which is probably bouncing for
the HIGHMEM pages in most if not all of the tests so results will
likely improve when bouncing is eliminated.

2419     = 2.4.19 + o(1) scheduler
2419rmap = 2.4.19 + rmap14b + o(1) scheduler

%sys/%user = ratio of %system CPU utilization to %user CPU utilization.

========================================
The results for the 3 GB mem test were :
========================================

kernel       msg/s  %CPU %sys/%user  Total swpin   Total swpout  Total swapio
-----------  -----  ---- ----------  ------------  ------------  ------------

2.4.19       ***** system hard hangs - requires reset. *****
2.4.19rmap   37767  76.9 1.46        2,274,380 KB  3,800,336 KB  6,074,716 KB

=============================== old data below===============================
2.5.26       51824  96.3 1.42        1,987,024 KB  2,148,100 KB  4,135,124 KB
2.5.26rmap   46053  90.8 1.55        3,139,324 KB  3,887,368 KB  7,026,692 KB
2.5.35       44693  86.1 1.45        1,982,236 KB  5,393,152 KB  7,375,388 KB
2.5.35mm1    39679  99.6 1.50       *2,720,600 KB *6,154,512 KB *8,875,112 KB

* used pgin/pgout instead of swapin/swapout since /proc/stat changed.

2.4.19 + o(1) hangs the system - requires reset.

2.4.19 + rmap13 + o(1) performance is degraded.  The baseline 2.4.19 hangs
after a couple of attempts so no direct comparision.  There are also peaks
of idle time during high swap activity.

========================================
The results for the 4 GB mem test were :
========================================

kernel       msg/s  %CPU %sys/%user  Total swpin   Total swpout  Total swapio
-----------  -----  ---- ----------  ------------  ------------  ------------

2.4.19       55386  99.8 1.40        0             0             0
2.4.19rmap   52330  99.5 1.43        0             2,363,388 KB  2,363,388 KB

=============================== old data below===============================
2.5.26       55446  99.4 1.40        0             0             0
2.5.35       52845  99.9 1.38        0             0             0
2.5.35mm1    52755  99.9 1.42        0             0             0

2.4.19 + o(1) using 4GB memory performs as well as 2.5.26.

2.4.19 + rmap14b + o(1) performance is down 5.5 % (52330/55386).
There was swap io even though we had 500MB free mem.

Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
