Message-ID: <20001019094007.12762.qmail@theseus.mathematik.uni-ulm.de>
From: ehrhardt@mathematik.uni-ulm.de
Date: Thu, 19 Oct 2000 11:40:07 +0200
Subject: Re: Page allocation (get_free_pages)
References: <001b01c0393f$bc79ddc0$c958fc3e@brain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001b01c0393f$bc79ddc0$c958fc3e@brain>; from p.hamshere@ntlworld.com on Wed, Oct 18, 2000 at 09:12:26PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "p.hamshere" <p.hamshere@ntlworld.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[ I inserted a few newlines in the quoted text ]

On Wed, Oct 18, 2000 at 09:12:26PM +0100, p.hamshere wrote:
> Hi
> I'm wondering why get_free_pages allocates contiguous pages for non-DMA
> transfers and why the kernel identity (ish) maps the whole (up to 1GB)
> of physical memory to its address space...

Messing with page tables is sloooow and you probably won't gain too much:
About 95% of all gfp allocations are single page anyway. A typical 2 page
(order 1) allocation is the task struct of a new process.
Now look what happens if we implement your idea:
We allocate one ore more physical pages, search for some free space in
the kernel's virtual address space and update the kernel page tables as
needed. Compare this to just grabbing the page from the free list and
toggling a few bits in the buddy bitmaps.

      regards   Christian

-- 

THAT'S ALL FOLKS!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
