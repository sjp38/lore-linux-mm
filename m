Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 17:18:28 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.10.10001131430520.13454-100000@mirkwood.dummy.home> from "Rik van Riel" at Jan 13, 2000 02:40:14 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E128ntG-0007sV-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, andrea@suse.de, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> I think that busier machines probably have a larger need
> for DMA memory than this code fragment will give us. I
> have the gut feeling that we'll want to keep about 512kB
> or more free in the lower 16MB of busy machines...

2.2.x  uses a simple algorithm. Normally allocations come from the main pool
if it fails we use the DMA pool. That seems to work just fine.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
