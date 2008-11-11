Date: Tue, 11 Nov 2008 16:25:23 -0200
From: Glauber Costa <glommer@redhat.com>
Subject: Re: [patch 0/7] vmalloc fixes and improvements #2
Message-ID: <20081111182523.GB20481@poweredge.glommer>
References: <20081110133515.011510000@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081110133515.011510000@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 11, 2008 at 12:35:15AM +1100, npiggin@suse.de wrote:
> Hopefully got attribution right.
> 
> Patches 1-3 fix "[Bug #11903] regression: vmalloc easily fail", and these
> should go upstream for 2.6.28. They've been tested and shown to fix the
> problem, and I've tested them here on my XFS stress test as well. The
> off-by-one bug, I tested and verified in a userspace test harness (it
> doesn't actually cause any corruption, but just suboptimal use of space).
> 
> Patches 4,5 are improvements to information exported to user. Not very risky,
> but not urgent either.
> 
> Patches 6,7 improve locking and debugging modes a bit. I have not included
> the changes to guard pages this time. They need a bit more explanation and
> code review to justify. And probably some more philosophical discussions on
> the mm list...
> 
> -- 

ok, news on this one inclusion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
