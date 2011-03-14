Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A987D8D0041
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 22:28:10 -0400 (EDT)
Message-ID: <20110316022804.27676.qmail@science.horizon.com>
From: George Spelvin <linux@horizon.com>
Date: Sun, 13 Mar 2011 20:20:44 -0400
Subject: [PATCH 0/8] mm/slub: Add SLUB_RANDOMIZE support
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, mpm@selenic.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@horizon.com

As a followup to the "[PATCH] Make /proc/slabinfo 0400" thread, this
is a patch series to randomize the order of object allocations within
a page.  It can be extended to SLAB and SLOB if desired.  Mostly it's
for benchmarking and discussion.

It Boots For Me(tm).

Patches 1-4 and 8 touch drivers/char/random.c, to add support for
efficiently generating a series of uniform random integers in small
ranges.  Is this okay with Herbert & Matt?

I did a bit of code cleanup while I was at it, but kept it to separate
patches.  Patches 4 and 7 are the heart of the new code, but I'd
particularly like comments on patch 8, as I don't understand the kconfig
stuff very well.  Is the feature description good and are the control
knobs adequate?

Checkpatch complains about a too-short CONFIG option description on
8/8; I think it's spurious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
