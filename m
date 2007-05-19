Date: Sat, 19 May 2007 03:40:57 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/8] mm: fix fault vs invalidate race for linear mappings
Message-ID: <20070519014057.GE15569@wotan.suse.de>
References: <200705180737.l4I7b4m4010748@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180812430.3890@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.98.0705180812430.3890@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 08:15:27AM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 18 May 2007, akpm@linux-foundation.org wrote:
> > 
> > Fix the race between invalidate_inode_pages and do_no_page.
> 
> Btw, I'm not merging this either. I think it's better done after we have 
> flags in the fault info, and people can return "btw, I already locked the 
> page for you" as a return value, rather than adding magic flags to 
> "vma->vm_flags" to tell the caller how they will behave.

We do have flags in the fault info. Returning that the page is locked is
is probably a good way to go. But that's a very minor change, and I would
prefer such a major bugfix to go into _existing_ code first than introducing
fault first.

Once we drop nopage support, then converting to something saner like that
should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
