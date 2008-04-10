Date: Thu, 10 Apr 2008 01:59:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: git-slub crashes on the t16p
Message-Id: <20080410015958.bc2fd041.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's the tree I pulled about 12 hours ago.  Quite early in boot.

crash: http://userweb.kernel.org/~akpm/p4105087.jpg
config: http://userweb.kernel.org/~akpm/config-t61p.txt
git-slub.patch: http://userweb.kernel.org/~akpm/mmotm/broken-out/git-slub.patch

A t61p is a dual-core x86_64.

I was testing with all of the -mm series up to and including git-slub.patch
applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
