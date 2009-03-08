Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 44F846B00A9
	for <linux-mm@kvack.org>; Sun,  8 Mar 2009 15:11:55 -0400 (EDT)
Date: Sun, 8 Mar 2009 12:11:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-Id: <20090308121143.0f8da203.akpm@linux-foundation.org>
In-Reply-To: <20090308165403.4d85da50@mjolnir.ossman.eu>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090307141316.85cb1f62.akpm@linux-foundation.org>
	<20090308110006.0208932d@mjolnir.ossman.eu>
	<20090308113619.0b610f31@mjolnir.ossman.eu>
	<20090308123825.GA25172@localhost>
	<20090308165403.4d85da50@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Wu Fengguang <fengguang.wu@intel.com>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 8 Mar 2009 16:54:03 +0100 Pierre Ossman <drzeus@drzeus.cx> wrote:

> I've gone through the dumps now, and still no meaningful difference.
> All the big bootmem allocations are present in both kernels, and the
> remaining memory in initcall is also the same for both (and doesn't
> really decrease by any meaningful amount).
> 
> I also tried booting with init=/bin/sh, and the lost memory is present
> even at that point.
> 

So we know that the memory gets consumed after end-of-initcalls and
before exec-of-init?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
