Date: Sat, 17 Apr 2004 12:19:55 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Might refill_inactive_zone () be too aggressive?
Message-ID: <20040417191955.GO743@holomorphy.com>
References: <20040417060920.GC29393@flea> <20040417061847.GC743@holomorphy.com> <20040417175723.GA3235@flea> <20040417181042.GM743@holomorphy.com> <20040417182838.GA3856@flea> <20040417183325.GN743@holomorphy.com> <20040417184424.GA4066@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040417184424.GA4066@flea>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc Singer <elf@buici.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 17, 2004 at 11:44:24AM -0700, Marc Singer wrote:
> That's a difficult thing to do.  My test setup uses an NFS root and
> the IO is over NFS.  Due to some oddities in the NFS code, performance
> is variable to a degree that does not make for good timing
> comparisons.  I'm looking for a way to enable TCP nfsroot mounts.
> Once this is working, I may be able to get some reliable numbers.
> It's your call about waiting for performance numbers.  As soon as I
> have better data, I'll post it.  Setting the swappiness flag does
> work, so I can give my users something for now.  It is possible that
> this will work for all cases that I'm ever going to see.  Setting
> swappiness to zero and the user mapping 50% of RAM will once again
> cause reclaim_mapped to go into action.  The difference is that with
> swappiness of 60, I'm not allowed to keep any mapped pages in RAM.  At
> swappiness of 0, I'm allows to keep half of total RAM mapped.

That's something of a normative question about the heuristics, and I
try to steer clear of those, though I'm not entirely sure that's how I
would interpret it the tunings for your descriptive parts.

In the absence of "hard" numbers, you might still be able to use things
like wall clock timings. Another thing that would help is to expose the
thing to a variety of workloads/etc. For that, I guess I post to lkml.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
