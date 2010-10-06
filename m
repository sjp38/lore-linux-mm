Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E05EC6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 17:02:15 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: HWPOISON/SLAB: Allow shrinking of specific slab cache.
Date: Wed,  6 Oct 2010 23:02:08 +0200
Message-Id: <1286398930-11956-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: penberg@cs.helsinki.fi, cl@linux-foundation.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

For hwpoison it is useful to shrink a specific slab cache: hwpoison
knows the page to shrink and attempts to free it.  Currently
it shrinks all slabs, which is a bit inefficient.

The slab caches internally all know this information, but do not
export it currently.

This patch kit adds a new function to export it and lets hwpoison
use it to shrink the correct page. I added the necessary functions
to slab, slub and slob.

Pekka, others, is this patch ok for you? I would prefer to carry in my
tree to avoid dependency issues.

Any reviews and Acks appreciated.

Thanks,
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
