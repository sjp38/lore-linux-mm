Message-ID: <39740568.FAD721A2@norran.net>
Date: Tue, 18 Jul 2000 09:21:12 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [PATCH] test5-pre1 vmfix (rev 8)
References: <3973AF65.F3372E@norran.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi again,

Correction:

I had forgot to start a background task during testing:
* Throuput gets up to 2% to 10% better for my tests.

/RogerL

Roger Larsson wrote:
> 
> Hi,
> 
> Since I am responsible for messing up some aspects of vm
> (when fixing others)
> here is a patch that tries to solve the introduced problems.
> 
> * no more periodic wake up of kswapd - not needed anymore
> * no more freeing all zones to (free_pages > pages_high)
> * always wakes kswapd up after try_to_free_pages
> * kswapd starts when all zones gets zone_wake_kswapd
>   (runs once for each zone that hits zone_wake_kswapd)
> * removed test for more than pages_high in alloc_pages,
>   zones will mostly be in the range [pages_high...pages_low]
> * I get 10% better throughput than 2.4.0-test4, YMMV
> 
> Note: logic of function keep_kswapd_awake has changed.
> 
> /RogerL
> 
> --
> Home page:
>   http://www.norran.net/nra02596/
> 
>   ------------------------------------------------------------------------
>                                   Name: patch-2.4.0-test5-1-vmfix.8
>    patch-2.4.0-test5-1-vmfix.8    Type: Plain Text (text/plain)
>                               Encoding: 7bit

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
