Message-ID: <3D274C6A.C6E23CAA@zip.com.au>
Date: Sat, 06 Jul 2002 13:00:42 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][RFT](2) minimal rmap for 2.5 - akpm tested
References: <3D268E19.B68559F6@zip.com.au> <Pine.LNX.4.44.0207061205001.1157-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Fri, 5 Jul 2002, Andrew Morton wrote:
> >
> > The box died, but not due to rmap.  We have a lock ranking
> > bug:
> >
> >         do_exit
> >         ->mmput
> >           ->exit_mmap                           page_table_lock
> >             ->removed_shared_vm_struct
> >               ->lock_vma_mappings               i_shared_lock
> 
> I _think_ we should just move the remove_shared_vm_struct() down into the
> case where we're closing the mapping, ie something like the appended.
> 
> That way we _only_ do the actual page table stuff under the page table
> lock, and do all the generic VM/FS stuff outside the lock.
> 
> Comments?

That is basically what do_munmap() does.  But I'm quite unfamiliar
with the locking in there.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
