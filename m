Date: Thu, 22 Mar 2001 19:22:08 +0100 (CET)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: Thinko in kswapd?
In-Reply-To: <E14g9X7-00030H-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.33.0103221911230.999-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, arjanv@redhat.com, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Mar 2001, Alan Cox wrote:

> > pull it all right back in again.  It continues through the entire
> > build with the cost seen in the time numbers.  (the ac20.virgin run
> > was worse by 30 secs than average, but that doesn't matter much)
>
> Using my reference interactive test (An application which renders 3D graphics
> and generates fairly measurable VM traffic with AGP texture mapping)[1] the
> graphical flow is noticably stalling where it didn't before.
>
> Throughput seems to be up but interactivity is bad.

If you set the amount that kswapd goes after to be a fraction of
inactive_target and leave Stephens change in but ensure that a
schedule happens between loops, IIRC interactive is pretty nice
while swapping.  (haven't tried that particular variant in a while)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
