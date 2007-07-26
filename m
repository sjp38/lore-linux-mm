Date: Wed, 25 Jul 2007 23:25:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/4] oom: extract deadlock helper function
Message-Id: <20070725232535.20b6032e.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.0.99.0707252311570.12071@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0707252311570.12071@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007 23:15:10 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> On Wed, 27 Jun 2007, David Rientjes wrote:
> 
> > Extracts the jiffies comparison operation, the assignment of the
> > last_tif_memdie actual, and diagnostic message to its own function.
> > 
> 
> Andrew, can you give me an update on where Andrea and I's patchsets for 
> the OOM killer stand for inclusion in -mm?  Andrea's were posted June 
> 8-13 and mine were posted June 27-28 to linux-mm.

Not forgotten about, but backlogged, and things are arriving at the same
rate as they are being dispatched, so no progress is being made.

(I could merge stuff faster, but my typing speed isn't the rate-limiting
factor here.  We're limited by our ability to review, integrate, test and
debug stuff).

If you have time, what would help heaps would be if you could adopt
Andrea's patches and then maintain those and yours as a single coherent
patchset.  Refresh, retest and squirt them all at me?

It'll take a lot of testing to test those things, and I haven't started to
think about how we set about that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
