Date: Fri, 14 Jan 2000 13:25:46 +0100
From: Jamie Lokier <lkd@tantalophile.demon.co.uk>
Subject: Re: [RFC] 2.3.39 zone balancing
Message-ID: <20000114132546.A18109@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0001132059590.981-100000@alpha.random> <200001132140.NAA27848@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200001132140.NAA27848@google.engr.sgi.com>; from Kanoj Sarcar on Thu, Jan 13, 2000 at 01:40:09PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Speaking of kswapd zone balancing.  Can swap cache pages be moved from
one zone to another, or even duplicated according to need later on?

It would seem logical that when a page in the DMA zone is only held for
swap cache, it's worth copying it to the regular zone and using the copy
when the page is needed again to free up DMA pages without hitting the
disk.

I guess this sort of preemptive duplication is in a similar category to
pre-zeroing.  

just a thought,
-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
