Date: Sun, 7 Jan 2001 17:07:59 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [patch] mm-cleanup-1 (2.4.0)
In-Reply-To: <87snmv9k13.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.21.0101071701250.4416-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On 7 Jan 2001, Zlatko Calusic wrote:

> The following patch cleans up some obsolete structures from the mm &
> proc code.
> 
> Beside that it also fixes what I think is a bug:
> 
>         if ((rw == WRITE) && atomic_read(&nr_async_pages) >
>                        pager_daemon.swap_cluster * (1 << page_cluster))
> 
> In that (swapout logic) it effectively says swap out 512KB at once (at
> least on my memory configuration). I think that is a little too much.
> I modified it to be a little bit more conservative and send only
> (1 << page_cluster) to the swap at a time. Same applies to the
> swapin_readahead() function. Comments welcome.

512kb is the maximum limit for in-flight swap pages, not the cluster size 
for IO. 

swapin_readahead actually sends requests of (1 << page_cluster) to disk
at each run.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
