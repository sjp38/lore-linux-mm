Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id B7F226B005D
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 11:06:54 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 0/3] move slabinfo processing to common code
Date: Fri, 28 Sep 2012 19:03:25 +0400
Message-Id: <1348844608-12568-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Hi,

This patch moves on with the slab caches commonization, by moving
the slabinfo processing to common code in slab_common.c. It only touches
slub and slab, since slob doesn't create that file, which is protected
by a Kconfig switch.

Enjoy,

v2: return objects per slab and cache order in slabinfo structure as well

Glauber Costa (3):
  move slabinfo processing to slab_common.c
  move print_slabinfo_header to slab_common.c
  sl[au]b: process slabinfo_show in common code

 mm/slab.c        | 118 ++++++++++++-------------------------------------------
 mm/slab.h        |  20 ++++++++++
 mm/slab_common.c | 109 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c        |  77 ++++++------------------------------
 4 files changed, 166 insertions(+), 158 deletions(-)

-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
