Message-Id: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:04 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/32] Swap over NFS - v19
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Patches are against: v2.6.27-rc5-mm1

This release features more comments and (hopefully) better Changelogs.
Also the netns stuff got sorted and ipv6 will now build and not oops
on boot ;-)

The first 4 patches are cleanups and can go in if the respective maintainers
agree.

The code is lightly tested but seems to work on my default config.

Let's get this ball rolling...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
