Message-Id: <4t153d$r2dpi@azsmga001.ch.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: Lockless page cache test results
Date: Wed, 26 Apr 2006 22:39:30 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060426194623.GD9211@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Jens Axboe' <axboe@suse.de>, 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, 'Nick Piggin' <npiggin@suse.de>, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jens Axboe wrote on Wednesday, April 26, 2006 12:46 PM
> > It's interesting, single threaded performance is down a little. Is
> > this significant? In some other results you showed me with 3 splices
> > each running on their own file (ie. no tree_lock contention), lockless
> > looked slightly faster on the same machine.
> 
> I can do the same numbers on a 2-way em64t for comparison, that should
> get us a little better coverage.


I throw the lockless patch and Jens splice-bench into our benchmark harness,
here are the numbers I collected, on the following hardware:

(1) 2P Intel Xeon, 3.4 GHz/HT, 2M L2
(2) 4P Intel Xeon, 3.0 GHz/HT, 8M L3
(3) 4P Intel Xeon, 3.0 GHz/DC/HT, 2M L2 (per core)

Here are the graph:

(1) 2P Intel Xeon, 3.4 GHz/HT, 2M L2
http://kernel-perf.sourceforge.net/splice/2P-3.4Ghz.png

(2) 4P Intel Xeon, 3.0 GHz/HT, 8M L3
http://kernel-perf.sourceforge.net/splice/4P-3.0Ghz.png

(3) 4P Intel Xeon, 3.0 GHz/DC/HT, 2M L2 (per core)
http://kernel-perf.sourceforge.net/splice/4P-3.0Ghz-DCHT.png

(4) everything on one graph:
http://kernel-perf.sourceforge.net/splice/splice.png

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
