Date: Mon, 15 May 2000 13:39:33 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Idea to improve the performance of the Kernel Memory Allocation
Message-ID: <20000515133933.A24812@redhat.com>
References: <391F6245.7D543933@feop.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <391F6245.7D543933@feop.com.br>; from gaqc@feop.com.br on Sun, May 14, 2000 at 11:34:45PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Guilherme Carvalho <gaqc@feop.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, May 14, 2000 at 11:34:45PM -0300, Guilherme Carvalho wrote:
> 
> If I am right, the buddy allocation algorithm first searches for blocks
> of pages of the size requested and follows the chain of free pages that
> is queued on the list element of the the free_area data structure.

No.  The free pages are held on linked lists, one list for each size.
We never have to follow free page chains looking for pages.  We just
allocate the first available free 4k page, and if no such page exists,
we find an 8k page, split it, and return one of the 4k subpages (the
other one is placed on the 4k free page list).

We never have to walk over more than one page of any given size.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
