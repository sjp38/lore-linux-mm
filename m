Received: from stingray.netplus.net (root@stingray.netplus.net [206.250.192.19])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA21769
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 13:45:13 -0500
Message-ID: <3698F4E1.715105C6@netplus.net>
Date: Sun, 10 Jan 1999 12:43:45 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
References: <Pine.LNX.3.95.990109213225.4665G-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:

> Can you run pre6+zlatko with just the mm/page_alloc.c one-liner reverted
> to pre5? That is, take pre6+zlatko, and just change
> 
>         try_to_free_pages(gfp_mask, freepages.high - nr_free_pages);
> 
> back to
> 
>         try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX);
> 

OK, here are the updated results:

'Image test' in 128MB:

pre6+zlatko's_patch     	2:35
and with requested change	3:09
pre6                    	2:27
pre5                    	1:58
arcavm13                	9:13


I also ran the kernel compile test:

In 12MB:
				Elapsed	Maj.	Min.	Swaps
				-----	------	------	-----
pre6+zlatko_patch       	22:14   383206  204482  57823
and with requested change	22:23	378662	198194	51445
pre6                    	20:54   352934  191210  48678
pre5                    	19:35   334680  183732  93427 
arcavm13                	19:45   344452  180243  38977

The change seems to have hurt it in both cases.  What I am seeing on pre6 and
it's derivitives is a *lot* of *swapin* activity.  Pre5 almost exclusively swaps
*out* during the image test, averaging about 1.25MB/sec (spends a lot of time at
around 2000k/sec) with very little swapping in.  All the pre6 derivitives swap
*in* quite heavily during the test.  The 'so' number sometimes drops to 0 for
seconds at a time.  It also looks like pre6 swaps out slightly more overall
(~165MB vs 160MB).

-Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
