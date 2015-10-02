Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5955882F99
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 09:03:50 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so32693684wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 06:03:49 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id ws7si13243461wjb.101.2015.10.02.06.03.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 06:03:48 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id A513099228
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 13:03:47 +0000 (UTC)
Date: Fri, 2 Oct 2015 14:03:45 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm: page_alloc: Hide some GFP internals and document the
 bits and flag combinations -fix
Message-ID: <20151002130345.GS3068@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-7-git-send-email-mgorman@techsingularity.net>
 <20150928165523.a52facb27c7ff4c29d902b6c@linux-foundation.org>
 <20150929133721.GJ3068@techsingularity.net>
 <560CF134.2060107@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <560CF134.2060107@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch address minor comment nitpicks from Vlastimil. It is a fix for the
mmotm patch
mm-page_alloc-hide-some-GFP-internals-and-document-the-bit-and-flag-combinations.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/gfp.h | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 67654f08a28b..4ab8cfa0aa9f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -110,17 +110,18 @@ struct vm_area_struct;
  *
  * __GFP_IO can start physical IO.
  *
- * __GFP_FS can call down to the low-level FS. Avoids the allocator
- *   recursing into the filesystem which might already be holding locks.
+ * __GFP_FS can call down to the low-level FS. Clearing the flag avoids the
+ *   allocator recursing into the filesystem which might already be holding
+ *   locks.
  *
  * __GFP_DIRECT_RECLAIM indicates that the caller may enter direct reclaim.
  *   This flag can be cleared to avoid unnecessary delays when a fallback
  *   option is available.
  *
- * __GFP_KSWAPD_RECLAIM indicates that the caller wants kswapd when the low
- *   watermark is reached and have it reclaim pages until the high watermark
- *   is reached. A caller may wish to clear this flag when fallback options
- *   are available and the reclaim is likely to disrupt the system. The
+ * __GFP_KSWAPD_RECLAIM indicates that the caller wants to wake kswapd when
+ *   the low watermark is reached and have it reclaim pages until the high
+ *   watermark is reached. A caller may wish to clear this flag when fallback
+ *   options are available and the reclaim is likely to disrupt the system. The
  *   canonical example is THP allocation where a fallback is cheap but
  *   reclaim/compaction may cause indirect stalls.
  *
@@ -208,11 +209,6 @@ struct vm_area_struct;
  *   for buffers that are mapped to userspace (e.g. graphics) that hardware
  *   still must DMA to. cpuset limits are enforced for these allocations.
  *
- * GFP_HIGHUSER is for userspace allocations that may be mapped to userspace,
- *   do not need to be directly accessible by the kernel but that cannot
- *   move once in use. An example may be a hardware allocation that maps
- *   data directly into userspace but has no addressing limitations.
- *
  * GFP_DMA exists for historical reasons and should be avoided where possible.
  *   The flags indicates that the caller requires that the lowest zone be
  *   used (ZONE_DMA or 16M on x86-64). Ideally, this would be removed but
@@ -223,6 +219,11 @@ struct vm_area_struct;
  * GFP_DMA32 is similar to GFP_DMA except that the caller requires a 32-bit
  *   address.
  *
+ * GFP_HIGHUSER is for userspace allocations that may be mapped to userspace,
+ *   do not need to be directly accessible by the kernel but that cannot
+ *   move once in use. An example may be a hardware allocation that maps
+ *   data directly into userspace but has no addressing limitations.
+ *
  * GFP_HIGHUSER_MOVABLE is for userspace allocations that the kernel does not
  *   need direct access to but can use kmap() when access is required. They
  *   are expected to be movable via page reclaim or page migration. Typically,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
