Received: from zero.aec.at (qmailr@zero.aec.at [193.170.192.102])
	by kvack.org (8.8.7/8.8.7) with SMTP id QAA20566
	for <linux-mm@kvack.org>; Sun, 5 Jul 1998 16:08:56 -0400
Subject: Re: current VM performance
References: <Pine.LNX.3.96.980705205234.2186A-100000@mirkwood.dummy.home>
From: Andi Kleen <ak@muc.de>
Date: 05 Jul 1998 21:03:17 +0200
In-Reply-To: Rik van Riel's message of Sun, 5 Jul 1998 21:00:18 +0200 (CEST)
Message-ID: <k27m1sdssq.fsf@zero.aec.at>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> Hi,
> 
> While considering future VM improvements, I decided to do
> some tests with the current VM subsystem.
> 
> I started with a 512x512 image (background of www.zip.com.au)
> in GIMP. The first thing I did was increasing the image size
> to 5120x5120, now I am 120M in swap on my 24M machine :-)

I'm not sure if the gimp is a good vm tester, because it basically
does its own VM with its tile based memory architecture. 

-Andi 
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
