Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA23037
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 15:42:15 -0500
Date: Sun, 10 Jan 1999 21:09:19 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
In-Reply-To: <Pine.LNX.3.95.990110105015.7668E-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990110210442.15845A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jan 1999, Linus Torvalds wrote:

> 
> 
> On Sun, 10 Jan 1999, Steve Bergman wrote:
> > 
> > The change seems to have hurt it in both cases.  What I am seeing on pre6 and
> > it's derivitives is a *lot* of *swapin* activity.  Pre5 almost exclusively swaps
> > *out* during the image test, averaging about 1.25MB/sec (spends a lot of time at
> > around 2000k/sec) with very little swapping in.  All the pre6 derivitives swap
> > *in* quite heavily during the test.  The 'so' number sometimes drops to 0 for
> > seconds at a time.  It also looks like pre6 swaps out slightly more overall
> > (~165MB vs 160MB).
> 
> This is interesting - the only thing that changed between pre5 and pre6
> (apart from the line that I asked you to revert and that made things
> worse) was actually the deadlock code. And the only thing _that_ changes,

I just given my explaination of why pre6 is completly unbalanced (even if
I have never run pre6 myself, but I just tried doing what pre6 does some
time before pre6 was out). I quote myself:

	I think there are problems with 2.2.0-pre6 VM (even if I have not tried it
	yet really). Latest time I tried on previous kernel to use in
	__get_free_pages() a try_to_free_pages weight > than MAX_SWAP_CLUSTER (aka
	freepages.high - nr_free_pages) I had bad impact of VM balance under
	swapping. 

	The problem is try_to_free_pages() implementation. Using a lower weight as
	in pre5 we was sure to return to shrink_mmap with more frequency and so
	getting more balance. Instead now we return to risk to only swapout
	without make real free memory space.

Your patch will not fix the problem. The problem is try_to_free_pages()
implementation.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
