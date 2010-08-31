Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4C56B0078
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 15:40:52 -0400 (EDT)
Message-Id: <20100831192617.441439071@chello.nl>
Date: Tue, 31 Aug 2010 21:26:17 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 0/5] mm, highmem: kmap_atomic rework -v2
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Next version of the kmap_atomic rework using Andrew's fancy CPP trickery to
avoid having to convert the whole tree at once.

This is compile tested for i386-allmodconfig, frv, mips-sb1250-swarm,
powerpc-ppc6xx_defconfig, sparc32_defconfig, arm-omap3 (all with
HIGHEM=y).

Boot-tested with: i386-defconfig.

Not tested with:
 - tile, stock toolchain doesn't build tile targets
 - nm10300, the arch doesn't build with highmem to begin with


Is this something we can live with?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
