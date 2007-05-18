Date: Fri, 18 May 2007 08:15:27 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 1/8] mm: fix fault vs invalidate race for linear
 mappings
In-Reply-To: <200705180737.l4I7b4m4010748@shell0.pdx.osdl.net>
Message-ID: <alpine.LFD.0.98.0705180812430.3890@woody.linux-foundation.org>
References: <200705180737.l4I7b4m4010748@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>


On Fri, 18 May 2007, akpm@linux-foundation.org wrote:
> 
> Fix the race between invalidate_inode_pages and do_no_page.

Btw, I'm not merging this either. I think it's better done after we have 
flags in the fault info, and people can return "btw, I already locked the 
page for you" as a return value, rather than adding magic flags to 
"vma->vm_flags" to tell the caller how they will behave.

So I guess this means that the whole series will be dropped now.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
