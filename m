Message-ID: <3915C053.EE77396C@sgi.com>
Date: Sun, 07 May 2000 12:13:23 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: [DATAPOINT] pre7-6 will not swap
References: <Pine.LNX.4.10.10005071048120.30202-100000@cesium.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: riel@nl.linux.org, Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 

> 
> It can also make the aging less efficient.
> 
> But my real reason for disliking it is that I prefer conceptually simple
> approaches, and that one test just doesn't fit conceptually ;)

Linus & Rik, agreed that the second_scan logic I proposed
earlier was not perfect.

And, I agree that we should make things simpler. One question
about what shrink_mmap is trying to accomplish, conceptually:

In the presense unreferenced pages in zones with free_pages > pages_high,
should shrink_mmap ever fail? Current shrink_mmap will
always skip over the pages of such zones. This in turn
can lead to swapping.


--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
