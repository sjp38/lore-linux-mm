Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 840A590014E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 06:53:32 -0400 (EDT)
Received: by mail-fx0-f41.google.com with SMTP id 9so6227406fxg.14
        for <linux-mm@kvack.org>; Mon, 01 Aug 2011 03:53:31 -0700 (PDT)
From: Per Forlin <per.forlin@linaro.org>
Subject: [PATCH -mmotm 2/2] fault-injection: export fault injection functions
Date: Mon,  1 Aug 2011 12:52:37 +0200
Message-Id: <1312195957-12223-3-git-send-email-per.forlin@linaro.org>
In-Reply-To: <1312195957-12223-1-git-send-email-per.forlin@linaro.org>
References: <1312195957-12223-1-git-send-email-per.forlin@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Per Forlin <per.forlin@linaro.org>

export symbols fault_should_fail() and fault_create_debugfs_attr() in order
to let modules utilize the fault injection

Signed-off-by: Per Forlin <per.forlin@linaro.org>
---
 lib/fault-inject.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/fault-inject.c b/lib/fault-inject.c
index c7af6d4..0b6c184 100644
--- a/lib/fault-inject.c
+++ b/lib/fault-inject.c
@@ -130,6 +130,7 @@ bool fault_should_fail(struct fault_attr *attr, ssize_t size)
 
 	return true;
 }
+EXPORT_SYMBOL_GPL(fault_should_fail);
 
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
