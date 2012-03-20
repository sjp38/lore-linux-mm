Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 1DD436B0083
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 06:16:26 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 0/6] add kmalloc_align()
Date: Tue, 20 Mar 2012 18:21:18 +0800
Message-Id: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lai Jiangshan <laijs@cn.fujitsu.com>

Add add kmalloc_align() for alignment requirement.
Almost no behavior changed nor overhead added.

Lai Jiangshan (6):
  kenrel.h: add ALIGN_OF_LAST_BIT()
  slub: add kmalloc_align()
  slab: add kmalloc_align()
  don't couple the header size with the alignment
  slob: add kmalloc_align()
  workqueue: use kmalloc_align() instead of hacking

 include/linux/kernel.h   |    2 ++
 include/linux/slab_def.h |    6 ++++++
 include/linux/slob_def.h |   14 +++++++++++++-
 include/linux/slub_def.h |    6 ++++++
 init/Kconfig             |    1 -
 kernel/workqueue.c       |   23 ++++++++-------------------------------------
 mm/slab.c                |    8 ++++----
 mm/slob.c                |   38 +++++++++++++++++++++-----------------
 mm/slub.c                |    2 +-
 9 files changed, 58 insertions(+), 41 deletions(-)

-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
