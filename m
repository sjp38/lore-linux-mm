Subject: Re: [RFC][DATA] re "ongoing vm suckage"
Date: Sun, 5 Aug 2001 21:23:57 +0100 (BST)
In-Reply-To: <Pine.LNX.4.33.0108051249570.7988-100000@penguin.transmeta.com> from "Linus Torvalds" at Aug 05, 2001 01:04:29 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15TURJ-0008Jy-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Mike Black <mblack@csihq.com>, Ben LaHaise <bcrl@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

> On Sun, 5 Aug 2001, Mike Black wrote:
> And quite frankly, if your disk can push 50MB/s through a 1kB
> non-contiguous filesystem, then my name is Bugs Bunny.

Hi Bugs 8), previously Frodo Rabbit, .. I think you watch too much kids tv
8)

[To be fair I can do this through a raid controller with write back caches
and the like ..]

> You're more likely to have a nice contiguous file, probably on a 4kB
> filesystem, and it should be able to do read-ahead of 127 pages in just a
> few requests.

One problem I saw with scsi was that non power of two readaheads were
causing lots of small I/O requests to actual hit the disk controller (which
hurt big time on hardware raid as it meant reading/rewriting chunks). I
ended up seeing 128/127/1 128/127/1 128/127/1 with a 255 block queue.

It might be worth logging the number of blocks in each request that hits
the disk layer and dumping them out in /proc. I'll see if I still have the
hack for that around.

Alan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
