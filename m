Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1CCCD6E0002
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:48:27 -0400 (EDT)
Subject: [PATCH/WIP] lmb cleanups and additions
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 May 2010 19:48:13 +1000
Message-ID: <1273484893.23699.86.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

(Resent that header email, git send-email is having hickups here)

This is my current WIP series. It's compile tested on ppc and sparc64 and
quickly boot tested on ppc64. The "advanced" features such as the new
array resize are completely untested in this version.

My aim is still to replace the bottom part of Yinghai's patch series
rather than build on top of it, and from there, add whatever he needs
to successfully port x86 over and turn NO_BOOTMEM into something half
decent without adding a ton of unneeded crap to the core lmb.

This is not finished tho. Here's a peek at my TODO list:

 - Move to mm/lmb.c

 - Various random return types with non-useful return codes (lmb_add, lmb_remove, ...)
   needs cleaning & documenting

 - Add docbook for all API functions

 - lmb_add or lmb_reserve of overlapping regions are going to wreck things in very
   interesting ways. We could easily error out but that's sub-optimal, instead we
   should break them up to only add/reserve the bits that aren't yet

 - Add some pr_debug in various places in there

 - Improve the NUMA interaction

In the meantime, comments are welcome :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
