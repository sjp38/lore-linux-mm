Subject: Re: Thinko in kswapd?
Date: Thu, 22 Mar 2001 18:09:59 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.33.0103221837360.665-100000@mikeg.weiden.de> from "Mike Galbraith" at Mar 22, 2001 06:53:18 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14g9X7-00030H-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, arjanv@redhat.com, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

> pull it all right back in again.  It continues through the entire
> build with the cost seen in the time numbers.  (the ac20.virgin run
> was worse by 30 secs than average, but that doesn't matter much)

Using my reference interactive test (An application which renders 3D graphics 
and generates fairly measurable VM traffic with AGP texture mapping)[1] the
graphical flow is noticably stalling where it didn't before.

Throughput seems to be up but interactivity is bad.

Alan

[1] Tux racer


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
