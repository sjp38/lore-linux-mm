Received: from halibut.imedia.com (halibut.imedia.com [206.3.97.123])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA25038
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 22:35:56 -0500
From: pmonta@halibut.imedia.com
Date: Sun, 24 Jan 1999 19:35:23 -0800
Message-Id: <199901250335.TAA07275@halibut.imedia.com>
In-reply-to: <m104ap4-0007U1C@the-village.bc.nu> (alan@lxorguk.ukuu.org.uk)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Reply-to: pmonta@imedia.com
References: <m104ap4-0007U1C@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
To: alan@lxorguk.ukuu.org.uk
Cc: torvalds@transmeta.com, linker@z.ml.org, sct@redhat.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox writes:

> I can't support devices needing large physically linear blocks of
> memory ...
>
> S3 Sonic Vibes	- linux can't support its wavetable (wants 4Mb linear)
> Zoran based capture chips - physically linear capture/masks
> Matrox Meteor frame grabber - physically linear grabbing
>
> So 2.3 needs to be able to allocate large linear physical spaces - not
> neccessarily efficiently either. These are all occasional grabs of memory.

Yes---physical addressing for I/O is reality.  Some devices may
not implement scatter-gather, and some may do so and yet still be
afflicted with high latencies for descriptor fetching and
the like.

If allocations are rare, it doesn't seem that unreasonable to actually
do physical copies, push stuff bodily out of the way to construct a new
contiguous region.  Or else a separate allocator, like the present-day
bigphysarea.

Cheers,
Peter Monta   pmonta@imedia.com
Imedia Corp.
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
