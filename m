Date: Thu, 12 Oct 2000 22:05:19 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
In-Reply-To: <200010130425.VAA11538@pizda.ninka.net>
Message-ID: <Pine.LNX.4.10.10010122203410.14174-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: saw@saw.sw.com.sg, davej@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tytso@mit.edu
List-ID: <linux-mm.kvack.org>


On Thu, 12 Oct 2000, David S. Miller wrote:
> 
>    page_table_lock is supposed to protect normal page table activity (like
>    what's done in page fault handler) from swapping out.
>    However, grabbing this lock in swap-out code is completely missing!
> 
> Audrey, vmlist_access_{un,}lock == unlocking/locking page_table_lock.

Yeah, it's an easy mistake to make.

I've made it myself - grepping for page_table_lock and coming up empty in
places where I expected it to be.

In fact, if somebody sends me patches to remove the "vmlist_access_lock()"
stuff completely, and replace them with explicit page_table_lock things,
I'll apply it pretty much immediately. I don't like information hiding,
and right now that's the only thing that the vmlist_access_lock() stuff is
doing.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
