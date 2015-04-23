Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4296B0078
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:33:44 -0400 (EDT)
Received: by wgin8 with SMTP id n8so13644729wgi.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 03:33:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ab3si31322946wid.70.2015.04.23.03.33.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 03:33:27 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/13] x86: mm: Enable deferred struct page initialisation on x86-64
Date: Thu, 23 Apr 2015 11:33:13 +0100
Message-Id: <1429785196-7668-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1429785196-7668-1-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Subject says it all. Other architectures may enable on a case-by-case
basis after auditing early_pfn_to_nid and testing.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b7d31ca55187..1beff8a8fbc9 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -18,6 +18,7 @@ config X86_64
 	select X86_DEV_DMA_OPS
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select HAVE_LIVEPATCH
+	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
 
 ### Arch settings
 config X86
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
