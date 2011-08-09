Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC906B016E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:08:11 -0400 (EDT)
Received: by mail-ew0-f41.google.com with SMTP id 9so1202990ewy.14
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 05:08:10 -0700 (PDT)
From: Per Forlin <per.forlin@linaro.org>
Subject: [PATCH --mmotm v8 3/3] fault injection: add documentation on MMC IO fault injection
Date: Tue,  9 Aug 2011 14:07:51 +0200
Message-Id: <1312891671-28680-4-git-send-email-per.forlin@linaro.org>
In-Reply-To: <1312891671-28680-1-git-send-email-per.forlin@linaro.org>
References: <1312891671-28680-1-git-send-email-per.forlin@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>, akpm@linux-foundation.org, Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Chris Ball <cjb@laptop.org>
Cc: linux-doc@vger.kernel.org, linux-mmc@vger.kernel.org, linaro-dev@lists.linaro.org, linux-mm@kvack.org, Per Forlin <per.forlin@linaro.org>

Add description on how to enable random fault injection
for MMC IO

Signed-off-by: Per Forlin <per.forlin@linaro.org>
Acked-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 Documentation/fault-injection/fault-injection.txt |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/Documentation/fault-injection/fault-injection.txt b/Documentation/fault-injection/fault-injection.txt
index 82a5d25..70f924e 100644
--- a/Documentation/fault-injection/fault-injection.txt
+++ b/Documentation/fault-injection/fault-injection.txt
@@ -21,6 +21,11 @@ o fail_make_request
   /sys/block/<device>/make-it-fail or
   /sys/block/<device>/<partition>/make-it-fail. (generic_make_request())
 
+o fail_mmc_request
+
+  injects MMC data errors on devices permitted by setting
+  debugfs entries under /sys/kernel/debug/mmc0/fail_mmc_request
+
 Configure fault-injection capabilities behavior
 -----------------------------------------------
 
@@ -115,7 +120,8 @@ use the boot option:
 
 	failslab=
 	fail_page_alloc=
-	fail_make_request=<interval>,<probability>,<space>,<times>
+	fail_make_request=
+	fail_mmc_request=<interval>,<probability>,<space>,<times>
 
 How to add new fault injection capability
 -----------------------------------------
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
