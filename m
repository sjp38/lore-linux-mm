Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 21:42:49 +0000 (GMT)
In-Reply-To: <200001132102.NAA20091@google.engr.sgi.com> from "Kanoj Sarcar" at Jan 13, 2000 01:02:19 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E128s14-0008DB-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> doc. If you have a large number of free regular pages, and the dma
> zone is completely exhausted, the 2.2 decision of balacing the dma
> zone might never fetch an "yes" answer, because it is based on total
> number of free pages, not also the per zone free pages. Right? Things 
> will get worse the more non-dma pages there are.

We might not make good choices to free ISA DMA pages, you are correct yes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
