Date: Fri, 18 May 2001 23:10:36 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: SMP/highmem problem
In-Reply-To: <20010519013544.A21549@flodhest.stud.ntnu.no>
Message-ID: <Pine.LNX.4.21.0105182307230.5531-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?Thomas_Lang=E5s?= <tlan@stud.ntnu.no>
Cc: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <kernel@ragnark.vestdata.no>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 19 May 2001, [iso-8859-1] Thomas Langas wrote:
> Rik van Riel:
> > A few fixes for this situation have gone into 2.4.5-pre2 and
> > 2.4.5-pre3. If you have the time, could you test if this problem
> > has gotten less or has gone away in the latest kernels ?
> 
> Ok, now we've tested 2.4.5-pre3, and it's still like described before.
> However, it's a bit better. 

Whooops, now that I looked at the source code for -pre3
I realise the particular patch which could fix this
problem hasn't gone into -pre3.

I'll send a patch SOON (almost like the one I sent a
few days ago, but with a few new fixes which have been
accumulating in the last few days).

> So, any other ideas are very welcome :)

The basis for the patch will be the page_alloc.c VM
patch on http://www.surriel.com/patches/, but with 2
minor changes:

1) don't allow GFP_BUFFER pages to loop in __alloc_pages(),
   but have them fail after a while ... needed to avoid
   deadlocks
2) never allow nr_free_buffer_pages to return a number
   larger than how many dirty pages would reasonably fit
   in ZONE_DMA and ZONE_NORMAL ... should fix your problem

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
