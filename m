Date: Thu, 12 Oct 2000 21:25:47 -0700
Message-Id: <200010130425.VAA11538@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <20001013123430.A8823@saw.sw.com.sg> (message from Andrey
	Savochkin on Fri, 13 Oct 2000 12:34:30 +0800)
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
References: <Pine.LNX.4.21.0010130114090.13322-100000@neo.local> <20001013123430.A8823@saw.sw.com.sg>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: saw@saw.sw.com.sg
Cc: davej@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tytso@mit.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

   page_table_lock is supposed to protect normal page table activity (like
   what's done in page fault handler) from swapping out.
   However, grabbing this lock in swap-out code is completely missing!

Audrey, vmlist_access_{un,}lock == unlocking/locking page_table_lock.

You've totally missed this and thus your suggested-patch/analysis
needs to be reevaluated :-)

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
