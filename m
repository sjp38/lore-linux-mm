Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
References: <Pine.LNX.4.21.0006050716160.31069-100000@duckman.distro.conectiva> <qww1z29ssbb.fsf@sap.com> <20000607143242.D30951@redhat.com>
From: Christoph Rohland <cr@sap.com>
Date: 07 Jun 2000 16:11:20 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 7 Jun 2000 14:32:42 +0100"
Message-ID: <qwwbt1dpomv.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Steven,

"Stephen C. Tweedie" <sct@redhat.com> writes:
> The swap cache --- which does handle anonymous pages --- is IN the
> page cache.  
> 
> The main reason SHM needs its own swap code is that normal anonymous
> pages are referred to only from ptes --- the ptes either point to
> the physical page containing the page, or to the swap entry.  We
> cannot use that for SHM, because SysV SHM segments must be persistent
> even if there are no attachers, and hence no ptes to maintain the 
> location of the pages.  
> 
> If it wasn't for persistent SHM segments, it would be trivial to
> integrate SHM into the normal swapper.

But for persistence we now have the shm dentries (We will have at
least. I am planning to reuse the ramfs directory handling for shm
fs. This locks the dentries into the cache for persistence). 

Couldn't we use this to get the desired behaviour? 

Just guessing
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
