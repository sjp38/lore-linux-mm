Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EC18C90010F
	for <linux-mm@kvack.org>; Thu, 26 May 2011 15:03:17 -0400 (EDT)
Message-Id: <20110526190300.120896512@linux.com>
Date: Thu, 26 May 2011 14:03:00 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub p1 0/4] SLUB: [RFC] Per cpu partial lists V1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

The following patchset applied on top of the lockless patchset V6 and
introduces per cpu partial lists. These lists help to avoid per node
locking overhead. The approach is not fully developed yet. Allocator
latency could be further reduced by making these operations work without
disabling interrupts (like the fastpath and the free slowpath) as well as
implementing better ways of handling ther cpu array with partial pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
