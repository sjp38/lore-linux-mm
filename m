Subject: Re: [PATCH] Fix races in 2.4.2-ac22 SysV shared memory
Date: Fri, 23 Mar 2001 22:20:05 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.31.0103231157200.766-100000@penguin.transmeta.com> from "Linus Torvalds" at Mar 23, 2001 11:58:50 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14gZuj-0005YN-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ben LaHaise <bcrl@redhat.com>, Christoph Rohland <cr@sap.com>
List-ID: <linux-mm.kvack.org>

> On Fri, 23 Mar 2001, Stephen C. Tweedie wrote:
> >
> > The patch below is for two races in sysV shared memory.
> 
> 	+       spin_lock (&info->lock);
> 	+
> 	+       /* The shmem_swp_entry() call may have blocked, and
> 	+        * shmem_writepage may have been moving a page between the page
> 	+        * cache and swap cache.  We need to recheck the page cache
> 	+        * under the protection of the info->lock spinlock. */
> 	+
> 	+       page = find_lock_page(mapping, idx);
> 
> Ehh.. Sleeping with the spin-lock held? Sounds like a truly bad idea.

Umm find_lock_page doesnt sleep does it ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
