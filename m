Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 21:53:44 +0000 (GMT)
In-Reply-To: <200001132150.NAA28314@google.engr.sgi.com> from "Kanoj Sarcar" at Jan 13, 2000 01:50:53 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E128sBd-0008FC-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> > We might not make good choices to free ISA DMA pages, you are correct yes
> 
> And given a huge enough HIGHMEM zone, we might not make good choices to free
> regular memory too, right?

I've got no empirical evidence from 2.2.x that the theoretical case occurs.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
