Message-ID: <20001013125013.A9180@saw.sw.com.sg>
Date: Fri, 13 Oct 2000 12:50:13 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
References: <Pine.LNX.4.21.0010130114090.13322-100000@neo.local> <20001013123430.A8823@saw.sw.com.sg> <200010130425.VAA11538@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200010130425.VAA11538@pizda.ninka.net>; from "David S. Miller" on Thu, Oct 12, 2000 at 09:25:47PM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: davej@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tytso@mit.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 12, 2000 at 09:25:47PM -0700, David S. Miller wrote:
>    Date: Fri, 13 Oct 2000 12:34:30 +0800
>    From: Andrey Savochkin <saw@saw.sw.com.sg>
> 
>    page_table_lock is supposed to protect normal page table activity (like
>    what's done in page fault handler) from swapping out.
>    However, grabbing this lock in swap-out code is completely missing!
> 
> Audrey, vmlist_access_{un,}lock == unlocking/locking page_table_lock.
> 
> You've totally missed this and thus your suggested-patch/analysis
> needs to be reevaluated :-)

Oops
You're of course right.
It looks as if somebody tried to separate this two locks and stopped in the
middle...

	Andrey
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
