Date: Tue, 22 May 2001 02:07:43 +0200
From: =?iso-8859-1?Q?Thomas_Lang=E5s?= <tlan@stud.ntnu.no>
Subject: Re: SMP/highmem problem
Message-ID: <20010522020742.A20434@flodhest.stud.ntnu.no>
Reply-To: tlan@stud.ntnu.no
References: <20010519013544.A21549@flodhest.stud.ntnu.no> <Pine.LNX.4.21.0105182307230.5531-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0105182307230.5531-100000@imladris.rielhome.conectiva>; from riel@conectiva.com.br on Fri, May 18, 2001 at 11:10:36PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: =?iso-8859-1?Q?Thomas_Lang=E5s?= <tlan@stud.ntnu.no>, =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <kernel@ragnark.vestdata.no>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel:
> > So, any other ideas are very welcome :)
> 
> The basis for the patch will be the page_alloc.c VM
> patch on http://www.surriel.com/patches/, but with 2
> minor changes:
> 
> 1) don't allow GFP_BUFFER pages to loop in __alloc_pages(),
>    but have them fail after a while ... needed to avoid
>    deadlocks

I added a counter which didn't "goto try_again" if it hit 10.

> 2) never allow nr_free_buffer_pages to return a number
>    larger than how many dirty pages would reasonably fit
>    in ZONE_DMA and ZONE_NORMAL ... should fix your problem

Made this function do return MIN(sum, ZONE_DMA+ZONE_NORMAL)

This did actually improve things _alot_ :)  We're going to perform some more
tests sometime tomorrow, but as far as I can tell, things are going way
better now than they did before. However, it might not be perfect yet...

-- 
-Thomas
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
