Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA03245
	for <linux-mm@kvack.org>; Tue, 17 Sep 2002 15:32:37 -0700 (PDT)
Message-ID: <3D87AD85.74C1CC2D@digeo.com>
Date: Tue, 17 Sep 2002 15:32:37 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: VolanoMark Benchmark results for 2.5.26, 2.5.26 + rmap, 2.5.35, and
 2.5.35 + mm1
References: <3D879B3B.9F326E20@austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Hartner <hartner@austin.ibm.com>
Cc: linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Bill Hartner wrote:
> 
> I ran VolanoMark 2.1.2 under memory pressure to test rmap.
>                              ---------------

Interesting test.  We really haven't begun to think about these
sorts of loads yet, alas.  Still futzing with lists, locks, 
IO scheduling, zone balancing, node balancing, etc.

Could someone please provide me with a simple set of instructions
to get volanomark up and running?   Including where to find a
JVM, etc?  I haven't even been able to locate the download for
volanomark.  Maybe that's a hint...

> ...
> 
> kernel      msg/s  %CPU %sys/%user  Total swpin   Total swpout  Total swapio
> ----------- -----  ---- ----------  ------------  ------------  ------------
> 2.5.26      51824  96.3 1.42        1,987,024 KB  2,148,100 KB  4,135,124 KB
> 2.5.26rmap  46053  90.8 1.55        3,139,324 KB  3,887,368 KB  7,026,692 KB
> 2.5.35      44693  86.1 1.45        1,982,236 KB  5,393,152 KB  7,375,388 KB
> 2.5.35mm1   39679  99.6 1.50       *2,720,600 KB *6,154,512 KB *8,875,112 KB

Strange that increased CPU utilisation (in userspace!) doesn't correlate with
increased throughput.
 
> * used pgin/pgout instead of swapin/swapout since /proc/stat changed.
> 
> 2.5.35 had the following errors after high and low mem were exhausted
> for the 3 GB test :
> 
> kswapd: page allocation failure. order:0, mode:0x50
> java: page allocation failure. order:0, mode:0x50

That's OK.  These warnings should have been suppressed, but a
bug in the suppression code lets them escape.
 
> On 2.5.35, I replaced the printk of the page allocation error with a global
> counter and ran 2.5.35 again.  The global counter indicated 5532 page
> allocation errors during the test and the throughput was 44371 msg/s.
> 
> These errors do not occur on 2.5.35 + mm1
> 
> The results for the 4 GB mem test were :
>                     --------
> kernel      msg/s  %CPU %sys/%user  Total swpin   Total swpout  Total swapio
> ----------- -----  ---- ----------  ------------  ------------  ------------
> 2.5.26      55446  99.4 1.40        0             0             0
> 2.5.35      52845  99.9 1.38        0             0             0
> 2.5.35mm1   52755  99.9 1.42        0             0             0
> 
> 2.5.26 vs 2.5.26 + rmap patch
> -----------------------------
> It appears as though the page stealing decisions made when using the
> 2.5.26 rmap patch may not be as good as the baseline for this workload.
> There was more swap activity and idle time.

Do you have similar results for 2.4 and 2.4-rmap?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
