Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA30670
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 14:39:28 -0500
Subject: Re: Results: 2.2.0-pre5 vs arcavm10 vs arcavm9 vs arcavm7
References: <Pine.LNX.3.95.990107093240.4270F-100000@penguin.transmeta.com> <87iueiudml.fsf@atlas.CARNet.hr>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 07 Jan 1999 20:38:49 +0100
In-Reply-To: Zlatko Calusic's message of "07 Jan 1999 19:44:18 +0100"
Message-ID: <87zp7uswja.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:

> 2) In pre-5, under heavy load, free memory is hovering around
> freepages.min instead of being somewhere between freepages.low &
> freepages.max. This could make trouble for bursts of atomic
> allocations (networking!).
> 

To followup myself, don't trust me, check your logfiles:

Jan  7 20:12:03 atlas kernel: eth0: Insufficient memory; nuking packet. 
Jan  7 20:12:05 atlas last message repeated 64 times

Uaaa, it's baaack... :)
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
