Date: Tue, 20 Jun 2000 13:01:30 -0400
From: willy@thepuffingroup.com
Subject: Re: shrink_mmap() change in ac-21
Message-ID: <20000620130130.I28546@vodka.thepuffingroup.com>
References: <87r99t8m2r.fsf@atlas.iskon.hr> <000d01bfda37$f34c3ee0$0a1e18ac@local> <dnaeggn4o0.fsf@magla.iskon.hr> <007501bfdad3$26288e90$0a1e18ac@local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <007501bfdad3$26288e90$0a1e18ac@local>; from Manfred Spraul on Tue, Jun 20, 2000 at 06:14:33PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: zlatko@iskon.hr, alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, Jun 20, 2000 at 06:14:33PM +0200, Manfred Spraul wrote:
> I'm also concerned about 1GB boxes:
> the highmem zone only contains ~ 64 MB (or 128?), and so most allocations go
> into a tiny zone and are then "downgraded" to GFP_NORMAL.

Not that I want to get involved with the VM system in _any way at all_,
but bcrl pointed out that highmem doesn't really cost a lot, so why not
change to:

3GB user space
512MB vmalloc space
512MB kernel space

i don't think there are many machines with amounts of RAM between 512MB
and 768MB so the worst case is that only 1/3 of the RAM is high, instead
of 1/8 (vmalloc is currently 128MB of 1GB).  i know jeff garzik wants
more vmalloc space for a frame grabber so maybe now is the right time
to make that change?

-- 
The Sex Pistols were revolutionaries.  The Bay City Rollers weren't.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
