Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 9EC876B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:41:07 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/4] move slabinfo processing to common code
Date: Thu, 27 Sep 2012 18:37:36 +0400
Message-Id: <1348756660-16929-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>

Hi,

This patch moves on with the slab caches commonization, by moving
the slabinfo processing to common code in slab_common.c. It only touches
slub and slab, since slob doesn't create that file, which is protected
by a Kconfig switch.

Enjoy,

Glauber Costa (4):
  move slabinfo processing to slab_common.c
  move print_slabinfo_header to slab_common.c
  slub: move slub internal functions to its header
  sl[au]b: process slabinfo_show in common code

 include/linux/slab_def.h |  10 ++++
 include/linux/slub_def.h |  25 ++++++++++
 mm/slab.c                | 116 ++++++++++-------------------------------------
 mm/slab.h                |  16 +++++++
 mm/slab_common.c         | 109 ++++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c                |  89 ++++--------------------------------
 6 files changed, 193 insertions(+), 172 deletions(-)

-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
