Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA27820
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 08:08:02 -0500
Date: Thu, 7 Jan 1999 13:02:50 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Results: 2.2.0-pre5 vs arcavm10 vs arcavm9 vs arcavm7
In-Reply-To: <36942ACA.3F8C055D@netplus.net>
Message-ID: <Pine.LNX.3.96.990107123008.310G-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jan 1999, Steve Bergman wrote:

> kernel	Time	Maj pf	Min pf  Swaps
> ----------	-----	------	------	-----
> 2.2.0-pre5	18:19	522333	493803	27984
> arcavm10	19:57	556299	494163	12035
> arcavm9	19:55	553783	494444	12077
> arcavm7	18:39	538520	493287	11526

Happy to hear that ! ;)

The changes in 2.2.0-pre5 looks really cool! I think the only missing
thing that I would like to see in is my calc_swapout_weight() thing. This
my change would avoid swap_out() to stall too much the system in presence
of huge tasks and so it would allow the VM to scale better... I'll do some
test starting from pre5 now...

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
