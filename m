Date: Wed, 7 Jun 2000 14:32:42 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
Message-ID: <20000607143242.D30951@redhat.com>
References: <Pine.LNX.4.21.0006050716160.31069-100000@duckman.distro.conectiva> <qww1z29ssbb.fsf@sap.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <qww1z29ssbb.fsf@sap.com>; from cr@sap.com on Wed, Jun 07, 2000 at 12:23:36PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 12:23:36PM +0200, Christoph Rohland wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> 
> > Awaiting your promised integration of SHM with the shrink_mmap
> > queue...
> 
> Sorry Rik, there was a misunderstanding here. I would really like to
> have this integration. But AFAICS this is a major task. shrink_mmap
> relies on the pages to be in the page cache and the pagecache does not
> handle shared anonymous pages.

The swap cache --- which does handle anonymous pages --- is IN the
page cache.  

The main reason SHM needs its own swap code is that normal anonymous
pages are referred to only from ptes --- the ptes either point to
the physical page containing the page, or to the swap entry.  We
cannot use that for SHM, because SysV SHM segments must be persistent
even if there are no attachers, and hence no ptes to maintain the 
location of the pages.  

If it wasn't for persistent SHM segments, it would be trivial to
integrate SHM into the normal swapper.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
