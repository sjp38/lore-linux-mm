Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B26416B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:13:46 -0400 (EDT)
Message-Id: <20100928131025.319846721@linux.com>
Date: Tue, 28 Sep 2010 08:10:25 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup5 0/3] SLUB: Cleanups V5
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

A couple of more cleanups (patches against Pekka's tree for next rebased to todays upstream)

1 Avoid #ifdefs by making data structures similar under SMP and NUMA

2 Avoid ? : by passing the redzone markers directly to the functions checking objects

3 Extract common code for removal of pages from partial list into a single function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
