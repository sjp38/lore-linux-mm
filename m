Date: Mon, 21 Jun 1999 20:31:19 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] [RFT] [PATCH] kanoj-mm9-2.2.10 simplify swapcache/shm code
 interaction
In-Reply-To: <14190.31634.420888.788269@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9906212026130.683-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jun 1999, Stephen C. Tweedie wrote:

>On Mon, 21 Jun 1999 10:17:10 -0700 (PDT), kanoj@google.engr.sgi.com
>(Kanoj Sarcar) said:
>
>> Okay, wrong choice of name on the parameter "shmfs". Would it help
>> to think of the new last parameter to rw_swap_page_base as "dolock",
>> which the caller has to pass in to indicate whether there is a 
>> swap lock map bit?

Kanoj did you took a look at my VM (I pointed out to you the url some time
ago). Here I just safely removed the swaplockmap completly. All the
page-contentions get automagically resolved from the swap cache also for
shm.c. I sent the relevant patches to Linus just before the page cache
code gone and the new page/buffer cache broken them in part. But now I am
running again rock solid with 2.3.7_andrea1 with SMP so if Linus will
agree I'll return to send him patches about such shm/swap-lockmap issue.
Just to show you:

andrea@laser:/usr/src$ cvs diff -u -r linux-2_3_7 linux/mm/page_io.c|diffstat
 page_io.c |  129 ++------------------------------------------------------------
 1 files changed, 6 insertions, 123 deletions

(should be enough to explain the thing :)

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
