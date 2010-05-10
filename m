Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 79B756200C2
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:39:52 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH/WIP] lmb cleanups and additions
Date: Mon, 10 May 2010 19:38:34 +1000
Message-Id: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

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
