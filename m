From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003271855.KAA57607@google.engr.sgi.com>
Subject: Re: [PATCH] Re: kswapd
Date: Mon, 27 Mar 2000 10:55:10 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10003270807260.1745-100000@penguin.transmeta.com> from "Linus Torvalds" at Mar 27, 2000 08:14:34 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: riel@nl.linux.org, Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> So think of the bug as "kswapd will waste the final part of its timeslice
> doing nothing useful".
>

Got it ... Thanks.

Makes you wonder whether the resched checking should be done for each zone, 
or once for the entire pgdat.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
