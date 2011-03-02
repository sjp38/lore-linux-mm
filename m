Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4A83B8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 03:38:24 -0500 (EST)
Received: by yib2 with SMTP id 2so2969408yib.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 00:38:23 -0800 (PST)
From: Liu Yuan <namei.unix@gmail.com>
Subject: [RFC PATCH 1/5] x86/Kconfig: Add Page Cache Accounting entry
Date: Wed,  2 Mar 2011 16:38:06 +0800
Message-Id: <1299055090-23976-1-git-send-email-namei.unix@gmail.com>
In-Reply-To: <no>
References: <no>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com

From: Liu Yuan <tailai.ly@taobao.com>

Signed-off-by: Liu Yuan <tailai.ly@taobao.com>
---
 arch/x86/Kconfig.debug |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/arch/x86/Kconfig.debug b/arch/x86/Kconfig.debug
index 615e188..f29e32d 100644
--- a/arch/x86/Kconfig.debug
+++ b/arch/x86/Kconfig.debug
@@ -304,4 +304,13 @@ config DEBUG_STRICT_USER_COPY_CHECKS
 
 	  If unsure, or if you run an older (pre 4.4) gcc, say N.
 
+config PAGE_CACHE_ACCT
+	bool "Page cache accounting"
+	---help---
+	  Enabling this options to account for page cache hit/missed number of
+	  times. This would allow user space applications get better knowledge
+	  of underlying page cache system by reading virtual file. The statitics
+	  per partition are collected.
+
+	  If unsure, say N.
 endmenu
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
