Date: Sun, 9 Jul 2000 14:11:09 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Swap clustering with new VM 
In-Reply-To: <20000706142945.A4237@redhat.com>
Message-ID: <Pine.LNX.4.21.0007091340520.14314-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Jul 2000, Stephen C. Tweedie wrote:

<snip> 

> For example, our swap clustering relies on allocating
> sequential swap addresses to sequentially scanned VM addresses, so
> that clustered swapout and swapin work naturally.  Switch to
> physically-ordered swapping and there's no longer any natural way of
> getting the on-disk swap related to VA ordering, so that swapin
> clustering breaks completely.  To fix this, you need the final swapout
> to try to swap nearby pages in VA space at the same time.  It's a lot
> of work to get it right.

AFAIK XFS's pagebuf structure contains a list of contiguous on-disk
buffers, so the filesystem can do IO on a pagebuf structure avoiding disk
seek time.

Do you plan to fix the swap clustering problem with a similar idea? 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
