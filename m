Subject: Re: [patch] mm-cleanup-1 (2.4.0)
References: <Pine.LNX.4.21.0101071701250.4416-100000@freak.distro.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 07 Jan 2001 22:11:45 +0100
In-Reply-To: Marcelo Tosatti's message of "Sun, 7 Jan 2001 17:07:59 -0200 (BRST)"
Message-ID: <dnitnrcbji.fsf@magla.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> On 7 Jan 2001, Zlatko Calusic wrote:
> 
> > The following patch cleans up some obsolete structures from the mm &
> > proc code.
> > 
> > Beside that it also fixes what I think is a bug:
> > 
> >         if ((rw == WRITE) && atomic_read(&nr_async_pages) >
> >                        pager_daemon.swap_cluster * (1 << page_cluster))
> > 
> > In that (swapout logic) it effectively says swap out 512KB at once (at
> > least on my memory configuration). I think that is a little too much.
> > I modified it to be a little bit more conservative and send only
> > (1 << page_cluster) to the swap at a time. Same applies to the
> > swapin_readahead() function. Comments welcome.
> 
> 512kb is the maximum limit for in-flight swap pages, not the cluster size 
> for IO. 
> 
> swapin_readahead actually sends requests of (1 << page_cluster) to disk
> at each run.
>  

OK, maybe I was too fast in concluding with that change. I'm still
trying to find out why is MM working bad in some circumstances (see my
other email to the list).

Anyway, I would than suggest to introduce another /proc entry and call
it appropriately: max_async_pages. Because that is what we care about,
anyway. I'll send another patch.
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
