Date: Mon, 25 Sep 2000 12:51:16 -0500 (CDT)
From: Jeff Garzik <jgarzik@mandrakesoft.mandrakesoft.com>
Subject: Re: the new VMt
In-Reply-To: <Pine.LNX.4.10.10009251227350.19220-100000@waste.org>
Message-ID: <Pine.LNX.3.96.1000925124937.2414P-100000@mandrakesoft.mandrakesoft.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oliver Xymoron <oxymoron@waste.org>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Oliver Xymoron wrote:
> Sure about that? It's been a while, but I seem to recall NT enforcing a
> scatter-gather framework on all drivers because it only gave them virtual
> allocations. For the cheaper cards, the s-g was done by software issuing
> single span requests to the card.

The Matrox framegrabber guys use some API under NT to allocate
megabytes upon megabytes of contiguous memory for DMA.

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
