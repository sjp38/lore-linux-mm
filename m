Date: Thu, 13 Feb 2003 10:26:12 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] early, early ioremap
Message-ID: <18530000.1045160770@[10.10.2.4]>
In-Reply-To: <3E4B4F36.70209@us.ibm.com>
References: <3E4B4F36.70209@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Because of some braindead hardware engineers, we need to map in some
> high memory areas just to find out how much memory we have, and where it
> is. (the e820 table doesn't cut it on this hardware)
> 
> I can't think of a good name for this.  It's earlier than bt_ioremap()
> and super_mega_bt_ioremap() doesn't have much of a ring to it.
> 
> This is only intended for remapping while the boot-time pagetables are
> still in use.  It was a pain to get the 2-level pgtable.h functions, so
> I just undef'd CONFIG_X86_PAE for my file.  It looks awfully hackish,
> but it works well.
> 
> Some of my colleagues prefer to steal ptes from some random source, then
> replace them when the remapping is done, but I don't really like this
> approach.  I prefer to know exactly where I'm stealing them from, which
> is where boot_ioremap_area[] comes in.

OK, rather than "some random source", how about we designate the window
from 7Mb - 8Mb as the early vmalloc space (akin to __VMALLOC_RESERVE),
and use that for early kmap / set_fixmap / whatever. I think that's
better than the array allocated from kernel data segment.

Either a per-page bitmap of used areas, a fixmap-type array, or simply
making the user keep track of it would be fine ...

Opinions?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
