Message-ID: <3B42CAA7.507F599F@earthlink.net>
Date: Wed, 04 Jul 2001 01:49:59 -0600
From: "Joseph A. Knapka" <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: [PATCH] initial detailed VM statistics code
References: <Pine.LNX.4.21.0107040107320.3257-100000@freak.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> 
> Hi,
> 
> Well, I've started working on VM stats code for 2.4.
> 

Thanks.

It might be useful to have a count of the number of PTEs scanned
by swap_out(), and the number of those that were unmapped. (I'm
interested in the scan rate of swap_out() vs refill_inactive_scan()).

I have a module that produces a histogram of pages-vs-age and
pages-vs-references for pages on the active_list, as well as
some other general VM stats; the code is available here:

<URL: http://home.earthlink.net/~jknapka/linux-mm/vmstatd1.c>

I'm not sure how generally useful it is, but you can make some
pretty pictures with it :-)

-- Joe Knapka
"You know how many remote castles there are along the gorges? You
 can't MOVE for remote castles!" -- Lu Tze re. Uberwald
// Linux MM Documentation in progress:
// http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
* Evolution is an "unproven theory" in the same sense that gravity is. *
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
