Subject: Re: shrink_mmap() change in ac-21
References: <Pine.LNX.4.21.0006200043550.988-100000@inspiron.random>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 20 Jun 2000 11:03:33 +0200
In-Reply-To: Andrea Arcangeli's message of "Tue, 20 Jun 2000 00:48:14 +0200 (CEST)"
Message-ID: <dnln0067x6.fsf@magla.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> writes:

> On Mon, 19 Jun 2000, Jamie Lokier wrote:
> 
> >if those wrong zones are quite full.  If the DMA zone desparately needs
> >free pages and keeps needing them, isn't it good to encourage future
> >non-DMA allocations to use another zone?  Removing pages from other
> 
> After some time the DMA zone will be full again anyway and you payed a
> cost that consists in throwing away unrelated innocent pages. I'm not
> convinced it's the right thing to do.
> 

Exactly!
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
