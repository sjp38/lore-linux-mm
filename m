From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200006222022.NAA47942@google.engr.sgi.com>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Date: Thu, 22 Jun 2000 13:22:13 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0006222124060.2692-100000@inspiron.random> from "Andrea Arcangeli" at Jun 22, 2000 09:26:56 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Timur Tabi <ttabi@interactivesi.com>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> On Wed, 21 Jun 2000, Timur Tabi wrote:
> 
> >So I suppose the best way to optimize this is to make sure that
> >"NR_GFPINDEX * sizeof(zonelist_t)" is a multiple of the cache line size?
> 
> Yes but only in SMP. On an UP compile you can save space. For this purpose
> in ac22-class there's a ____cacheline_aligned_in_smp macro that you can
> use for things like that (it relies on the compiler enterely).
> 
> Andrea

Umm, careful. If you happen to share a cacheline between a readonly array 
and a frequently updated variable, it might be better not to delete
unused elements from an array - that way, you might be able to bunch up
all the frequently updated variables into their own cacheline, and save
the memory write back of an extra cacheline.

BTW, this is all of course nitpicking.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
