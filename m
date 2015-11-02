Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 382D382F65
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 12:01:37 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so29716980pab.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 09:01:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cz1si36210914pbc.92.2015.11.02.09.01.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 09:01:34 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/5] KSM updates v2
Date: Mon,  2 Nov 2015 18:01:26 +0100
Message-Id: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Hello,

This practically the same as the previous submit but without the first
patch which luckily turned out to be a noop. Some commit message have
been improved on the way.

Dropping the first patch would generate rejects on the later patches
so this is a clean submit against v4.3.

The cond_resched() for the rmap walks is not only for KSM but it's
primarily a KSM improvement as KSM generates much heavier rmap walks
than the other rmap mechanisms would, so I'm submitting it in KSM
context.

All patches in this submit have been acked by Hugh already, thanks for
the help!

Andrea Arcangeli (5):
  mm: add cond_resched() to the rmap walks
  ksm: don't fail stable tree lookups if walking over stale stable_nodes
  ksm: use the helper method to do the hlist_empty check
  ksm: use find_mergeable_vma in try_to_merge_with_ksm_page
  ksm: unstable_tree_search_insert error checking cleanup

 mm/ksm.c  | 49 +++++++++++++++++++++++++++++++++++--------------
 mm/rmap.c |  4 ++++
 2 files changed, 39 insertions(+), 14 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
