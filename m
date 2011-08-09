Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D9E4B6B016E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 05:48:12 -0400 (EDT)
Received: by eyh6 with SMTP id 6so4221758eyh.20
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 02:48:10 -0700 (PDT)
From: Per Forlin <per.forlin@linaro.org>
Subject: [PATCH --mmotm v6 1/3] fault-inject: export fault injection functions
Date: Tue,  9 Aug 2011 11:47:46 +0200
Message-Id: <1312883268-4342-2-git-send-email-per.forlin@linaro.org>
In-Reply-To: <1312883268-4342-1-git-send-email-per.forlin@linaro.org>
References: <1312883268-4342-1-git-send-email-per.forlin@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>, akpm@linux-foundation.org, Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Chris Ball <cjb@laptop.org>
Cc: linux-doc@vger.kernel.org, linux-mmc@vger.kernel.org, linaro-dev@lists.linaro.org, linux-mm@kvack.org, Per Forlin <per.forlin@linaro.org>

export symbols should_fail() and fault_create_debugfs_attr() in order
to let modules utilize the fault injection

Signed-off-by: Per Forlin <per.forlin@linaro.org>
Acked-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 lib/fault-inject.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/fault-inject.c b/lib/fault-inject.c
index f193b77..328d433 100644
--- a/lib/fault-inject.c
+++ b/lib/fault-inject.c
@@ -130,6 +130,7 @@ bool should_fail(struct fault_attr *attr, ssize_t size)
 
 	return true;
 }
+EXPORT_SYMBOL_GPL(should_fail);
 
 #ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
 
@@ -243,5 +244,6 @@ fail:
 
 	return ERR_PTR(-ENOMEM);
 }
+EXPORT_SYMBOL_GPL(fault_create_debugfs_attr);
 
 #endif /* CONFIG_FAULT_INJECTION_DEBUG_FS */
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
