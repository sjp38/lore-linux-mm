Message-Id: <4t16i2$r2lk1@orsmga001.jf.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: Lockless page cache test results
Date: Thu, 27 Apr 2006 00:51:34 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <200604270815.18575.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andi Kleen' <ak@suse.de>
Cc: 'Jens Axboe' <axboe@suse.de>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, 'Nick Piggin' <npiggin@suse.de>, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote on Wednesday, April 26, 2006 11:15 PM
> On Thursday 27 April 2006 07:39, Chen, Kenneth W wrote:
> > (1) 2P Intel Xeon, 3.4 GHz/HT, 2M L2
> > http://kernel-perf.sourceforge.net/splice/2P-3.4Ghz.png
> > 
> > (2) 4P Intel Xeon, 3.0 GHz/HT, 8M L3
> > http://kernel-perf.sourceforge.net/splice/4P-3.0Ghz.png
> > 
> > (3) 4P Intel Xeon, 3.0 GHz/DC/HT, 2M L2 (per core)
> > http://kernel-perf.sourceforge.net/splice/4P-3.0Ghz-DCHT.png
> > 
> > (4) everything on one graph:
> > http://kernel-perf.sourceforge.net/splice/splice.png
> 
> Looks like a clear improvement for lockless unless I'm misreading the
> graphs. (Can you please use different colors next time?)


Sorry, I'm a bit rusty with gnuplot. Color charts are updated with the
same url.  On the last one, I was trying to plot same CPU type with same
color but different line weight for each kernel, 

plot "data" using 1:2 title "2P Xeon 3.4 GHz - vanilla" with linespoints lt 1 lw 10, \
     "data" using 1:3 title "2P Xeon 3.4 GHz - lockless" with linespoints lt 1 lw 1

gnuplot gives me the same color on both plotted lines, but the line weight
argument doesn't have any effect.  I looked for examples everywhere on the
web with no avail.  I must be missing some argument somewhere that I can't
figure out right now :-(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
