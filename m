From: Anton Salikhmetov <salikhmetov@gmail.com>
Subject: [PATCH -v8 0/4] Fixing the issue with memory-mapped file times
Date: Wed, 23 Jan 2008 02:21:16 +0300
Message-Id: <12010440803930-git-send-email-salikhmetov@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

This is the eighth version of my solution for the bug #2645:

http://bugzilla.kernel.org/show_bug.cgi?id=2645

Since the previous version, the following has changed:

1) based on Linus' comment, a more efficient PTE walker implemented;

2) the design document added to the kernel documentation.

Functional tests successfully passed.

Please comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
