Date: Wed, 7 Mar 2007 11:24:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC} memory unplug patchset prep [0/16]
Message-Id: <20070307112450.b7917dcc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0703060145570.22477@chino.kir.corp.google.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0703060145570.22477@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007 07:24:52 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 6 Mar 2007, KAMEZAWA Hiroyuki wrote:
> 
> > My purpose is to show how memory-unplug can be implemented on ZONE_MOVABLE.
> > *Any* comments are welcome. This patch just support ia64, which I can test.
> > If you want me to add arch support, please mail me.
> > 
> 
> It's great to see progress being made in the memory hot-unplug direction.  
> The implementation seems to be following the plan you had in our 
> coversations from the end of last year.
> 
> > This patch is a bit old and against 2.6.20-mm2. I'll rebase this and reflect
> > your comments in the next post (may not soon).
> > Well booted on ia64 and passed *quick* memory offline test.
> > 
> 
> When it's rebased, it might be better to apply it to the latest -mm with 
> Mel Gorman's patch series merged.  They're in 2.6.21-rc2-mm2.
> 
I will do.

> It appears as though you're using a subset of the ZONE_MOVABLE patches as 
> posted from March 1.  What about the additional capabilities of 
> ZONE_MOVABLE that aren't included in your patchset, such as allowing 
> hugetlb pages from being allocated under GFP_HIGH_MOVABLE, are going to 
> need to be changed to support memory hot-unplug?

We need extra patches for "migrating HUGEPAGE". It's in my plan but not
scheduled yet.

>  Since your patchset 
> wasn't based on the entire ZONE_MOVABLE set, it leads me to believe that 
> some of what it does diverges with the memory hot-unplug use case.
> 
> Are you aiming to target both ia64 and x86_64 with this patchset or are 
> you focusing on ia64 exclusively at the moment?
> 
Just because a machine, which I can use as much as I want, is ia64.
I don't have x86_64 now. I'll add i386 in the next post.
I think all arch which support MEMORY_HOTPLUG will support unplug at last.

-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
