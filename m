From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906211912.MAA79202@google.engr.sgi.com>
Subject: Re: [RFC] [RFT] [PATCH] kanoj-mm9-2.2.10 simplify swapcache/shm code
Date: Mon, 21 Jun 1999 12:12:18 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9906212026130.683-100000@laser.random> from "Andrea Arcangeli" at Jun 21, 99 08:31:19 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: sct@redhat.com, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> 
> On Mon, 21 Jun 1999, Stephen C. Tweedie wrote:
> 
> >On Mon, 21 Jun 1999 10:17:10 -0700 (PDT), kanoj@google.engr.sgi.com
> >(Kanoj Sarcar) said:
> >
> >> Okay, wrong choice of name on the parameter "shmfs". Would it help
> >> to think of the new last parameter to rw_swap_page_base as "dolock",
> >> which the caller has to pass in to indicate whether there is a 
> >> swap lock map bit?
> 
> Kanoj did you took a look at my VM (I pointed out to you the url some time
> ago). Here I just safely removed the swaplockmap completly. All the
> page-contentions get automagically resolved from the swap cache also for
> shm.c. I sent the relevant patches to Linus just before the page cache
> code gone and the new page/buffer cache broken them in part. But now I am
> running again rock solid with 2.3.7_andrea1 with SMP so if Linus will
> agree I'll return to send him patches about such shm/swap-lockmap issue.
> Just to show you:
>

I skimmed thru your patch earlier, but was too lazy to concentrate
on the details ...

I took the time now to look into your changes to page_io.c and shm.c,
and I like it better than the current code, for the reason that pages 
marked PageSwapCache will actually end up being in the swap cache. 
Which is what I was trying to do in my patch ...

If Linus is willing to take your patch, we can stop talking about
mine ...

Thanks.

Kanoj
kanoj@engr.sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
