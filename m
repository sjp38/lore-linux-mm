From: Anton Salikhmetov <salikhmetov@gmail.com>
Subject: [PATCH -v7 0/2] Fixing the issue with memory-mapped file times
Date: Tue, 22 Jan 2008 03:32:34 +0300
Message-Id: <12009619562023-git-send-email-salikhmetov@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

This is the seventh version of my solution for the bug #2645:

http://bugzilla.kernel.org/show_bug.cgi?id=2645

Since the previous version, the following has changed: based on
Linus' comment, SMP-safe PTE update implemented.

Discussions, which followed my past submissions, showed that it was
tempting to approach this problem using very different assumptions.
However, many such designs have proved to be incomplete or inefficient.

Taking into account the obvious complexity of this problem, I prepared a
design document, the purpose of which is twofold. First, it summarizes
previous attempts to resolve the ctime/mtime issue. Second, it attempts
to prove that what the patches do is necessary and sufficient for mtime
and ctime update provided that we start from a certain sane set of
requirements. The design document is available via the following link:

http://bugzilla.kernel.org/show_bug.cgi?id=2645#c40

For the seventh version, comprehensive performance testing was performed.
The results of performance tests, including numbers, are available here:

http://bugzilla.kernel.org/show_bug.cgi?id=2645#c43

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
