Date: Fri, 16 Feb 2007 14:35:46 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: NUMA replicated pagecache
Message-ID: <20070216133545.GB3036@wotan.suse.de>
References: <20070213060924.GB20644@wotan.suse.de> <1171485124.5099.43.camel@localhost> <20070215003810.GE29797@wotan.suse.de> <1171582169.5114.86.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1171582169.5114.86.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 15, 2007 at 06:29:29PM -0500, Lee Schermerhorn wrote:
> 
> I've attached another patch that closes one race and fixes a context
> problem [irq/preemption state] in __unreplicate_page_range().  This
> makes the locking even uglier :-(.
> 
> I get further with this patch.  Boot all the way up and can run fine
> with page replication.  However, I still get a NULL pcd in
> find_get_page_readonly() when attempting a highly parallel kernel build
> [16cpu/4node numa platform].  I'm still trying to track that down.

OK, before you get further with your testing, I have done a rework. Sorry
you had to wade through that last lot of uncommented spaghetti. This
upcoming version should actually be a reasonable base to do testing and
development on.

> Question about locking:  looks like the pcache_descriptor members are
> protected by the tree_lock of the mapping, right?

Yes. I figured that this would be cleanest and simplest for now. This
locking model is retained in the rework.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
