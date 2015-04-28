Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A65E6B0081
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:37:40 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so153886703wgy.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:37:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ez17si38767362wjc.157.2015.04.28.07.37.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 07:37:22 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/13] x86: mm: Enable deferred struct page initialisation on x86-64
Date: Tue, 28 Apr 2015 15:37:07 +0100
Message-Id: <1430231830-7702-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1430231830-7702-1-git-send-email-mgorman@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
