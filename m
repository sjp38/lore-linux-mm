From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906282138.OAA36935@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
Date: Mon, 28 Jun 1999 14:38:43 -0700 (PDT)
In-Reply-To: <Pine.BSO.4.10.9906281715420.24888-100000@funky.monkey.org> from "Chuck Lever" at Jun 28, 99 05:32:05 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: andrea@suse.de, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> (i also tried down_trylock, but discarded it.)
> 
> well, except that kswapd itself doesn't free any memory.  it simply copies
> data from memory to disk.  shrink_mmap() actually does the freeing, and
> can do this with minimal locking, and from within regular application
> processes.  when a process calls shrink_mmap(), it will cause some pages
> to be made available to GFP.
> 

The page is not really free for reallocation, unless kswapd can
push out the contents to disk, right? Which means, kswapd should
have as minimal sleep/memallocation points as possible ...

Kanoj
kanoj@engr.sgi.com

> if you need evidence that shrink_mmap() will keep a system running without
> swapping, just run 2.3.8 :) :)
> 
> come to think of it, i don't think there is a safety guarantee in this
> mechanism to prevent a lock-up.  i'll have to think more about it.
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
