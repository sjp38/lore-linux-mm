Date: Thu, 22 Jun 2000 21:51:29 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Message-ID: <20000622215129.D28360@pcep-jamie.cern.ch>
References: <20000621213507Z131177-21003+34@kanga.kvack.org> <Pine.LNX.4.21.0006222124060.2692-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0006222124060.2692-100000@inspiron.random>; from andrea@suse.de on Thu, Jun 22, 2000 at 09:26:56PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Timur Tabi <ttabi@interactivesi.com>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> >So I suppose the best way to optimize this is to make sure that
> >"NR_GFPINDEX * sizeof(zonelist_t)" is a multiple of the cache line size?
> 
> Yes but only in SMP. On an UP compile you can save space. For this purpose
> in ac22-class there's a ____cacheline_aligned_in_smp macro that you can
> use for things like that (it relies on the compiler enterely).

Does ____cacheline_aligned_in_smp guarantee the _size_ of the object is
aligned, or merely its address?

You can always make an array of one element containing an aligned object
I suppose.

Longer term some variation of the per-CPU data area patch should be used.
If only it can be made nice :-)

-- jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
