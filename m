Date: Fri, 15 Jun 2001 11:07:09 -0400
From: Chris Mason <mason@suse.com>
Subject: Re: [PATCH] Avoid !__GFP_IO allocations to eat from memory
 reservations
Message-ID: <651290000.992617629@tiny>
In-Reply-To: <20010614142822Z131175-12594+95@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Thursday, June 14, 2001 09:59:43 AM -0300 Marcelo Tosatti
<marcelo@conectiva.com.br> wrote:

> 
> In pre3, GFP_BUFFER allocations can eat from the "emergency" memory
> reservations in case try_to_free_pages() fails for those allocations in
> __alloc_pages(). 
> 
> 
> Here goes the (tested) patch to fix that: 

I started testing this because I expected problems under load with reiserfs
on it.  No deadlocks yet though...I owe Marcelo a beer ;-)

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
