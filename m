Date: Tue, 20 Jun 2000 21:00:51 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: shrink_mmap() change in ac-21
In-Reply-To: <yttbt0wmerg.fsf@serpe.mitica>
Message-ID: <Pine.LNX.4.21.0006202055050.3438-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Manfred Spraul <manfred@colorfullife.com>, Rik van Riel <riel@conectiva.com.br>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 20 Jun 2000, Juan J. Quintela wrote:

>memory...)  Perhaps it is too late to solve that problem for 2.4, but
>it appears that somebody needs to think a bit about the problem.

Incidentally I just thought about this and I fixed the problem at
2.3.99-pre2 time. With classzone design if nobody is doing a GFP_DMA
allocation (and nobody is doing that because as you said you don't have
soundcard and you don't use the floppy) then _nobody_ will ever to try to
take some page free from the DMA zone. The DMA zone can be shrink of
course but it will be considered as a whole with the NORMAL zone. Or see
it in another way: when you'll do a GFP_KERNEL allocation the kernel will
behave exactly if you would have only one zone (if you have less than 1
giga of ram of course).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
