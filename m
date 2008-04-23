Date: Wed, 23 Apr 2008 18:25:50 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 12/18] hugetlbfs: support larger than MAX_ORDER
Message-ID: <20080423162550.GD29087@one.firstfloor.org>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.965631000@nick.local0.net> <480F608B.90100@cray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <480F608B.90100@cray.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Hastings <abh@cray.com>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 11:15:07AM -0500, Andrew Hastings wrote:
> npiggin@suse.de wrote:
> >This is needed on x86-64 to handle GB pages in hugetlbfs, because it is
> >not practical to enlarge MAX_ORDER to 1GB. 
> 
> Sorry to ask what is probably a dumb question, but why is it not 
> practical to increase MAX_ORDER to 1GB for a 64-bit platform like 
> x86-64?  

That would mean all zones would need to be 1GB aligned.
That would make it impossible to have a 16MB zone dma and
the following normal zone. That one is actually going 
away with the mask allocator patchkit, but also the
movable zone is not necessarily aligned to 1GB.

The other issue is that it would increase the cache foot print
of the page allocator significantly and that is very sensitive
in important benchmarks.

> Doing so would make 1GB pages much more practical to use.

It's very doubtful that even with an increased MAX_ORDER you would
be actually able to allocate GB pages efficiently after boot.
Even with all tricks like movable zone etc.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
