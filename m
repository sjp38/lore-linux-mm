Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA17227
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 00:37:08 -0500
Date: Sat, 9 Jan 1999 21:35:40 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
In-Reply-To: <3697F442.222A2301@netplus.net>
Message-ID: <Pine.LNX.3.95.990109213225.4665G-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



On Sat, 9 Jan 1999, Steve Bergman wrote:
> 
> I ran the "image test" (loading 116 jpg images simultaneously) on the latest
> patches and got these results in 128MB (I end up with ~ 160MB in swap):
> 
> pre6+zlatko's_patch	2:35
> pre6			2:27
> pre5			1:58
> arcavm13		9:13

Can you run pre6+zlatko with just the mm/page_alloc.c one-liner reverted
to pre5? That is, take pre6+zlatko, and just change 

	try_to_free_pages(gfp_mask, freepages.high - nr_free_pages);

back to

	try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX);

That particular one-liner was almost certainly a mistake, it was done on
the mistaken assumption that the clustering problem was due to
insufficient write-time clustering - while zlatko found that it was
actually due to fragmentation in the swap area. With zlatkos patch, the
original SWAP_CLUSTER_MAX is probably better and almost certainly results
in smoother behaviour due to less extreme free_pages.. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
