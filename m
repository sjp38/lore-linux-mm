Date: Thu, 22 Jun 2000 21:26:56 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
In-Reply-To: <20000621213507Z131177-21003+34@kanga.kvack.org>
Message-ID: <Pine.LNX.4.21.0006222124060.2692-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jun 2000, Timur Tabi wrote:

>So I suppose the best way to optimize this is to make sure that
>"NR_GFPINDEX * sizeof(zonelist_t)" is a multiple of the cache line size?

Yes but only in SMP. On an UP compile you can save space. For this purpose
in ac22-class there's a ____cacheline_aligned_in_smp macro that you can
use for things like that (it relies on the compiler enterely).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
