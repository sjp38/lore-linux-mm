Message-ID: <4202B8C9.2040605@cyberone.com.au>
Date: Fri, 04 Feb 2005 10:50:33 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: lru_add_drain query
References: <42025DCF.2080004@sgi.com>
In-Reply-To: <42025DCF.2080004@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Ray Bryant wrote:

> The deferred lru_add operations (e. g. lru_cache_add_active()) defer the
> actual addition of a page to the lru list until a batch of such additions
> are available.  lru_cache_add_active() uses a per cpu variable 
> (lru_add_active_pvecs) to hold the deferred pages.
>
> So, to get the deferred adds to complete (so that the lru list is in a
> consistent state and we can scan lru list to do some processing) one 
> calls
> lru_add_drain().  But AFAI can tell, this just drains the local cpu's
> deferred add queue.  Right?
>
> So, here's my question:  Why is it that I don't need to call 
> lru_add_drain()
> on each CPU in the system before I go scan/manipulate the lru list?  
> (i. e.
> what about deferred adds in other CPU's lru_add_active_pvecs?)
>
> What peice of magic am I missing here?
>

I don't think you're missing anything. See lru_drain_cache for when you
really need to drain another CPU's cache (ie cpu hotplug).

I think the idea is that it doesn't _really_ matter to have a few pages
not visible to the LRU lists at any point in time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
