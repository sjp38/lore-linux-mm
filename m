Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E3DA6900137
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 07:49:31 -0400 (EDT)
Received: by mail-ey0-f175.google.com with SMTP id 6so4295175eyh.20
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 04:49:30 -0700 (PDT)
From: Per Forlin <per.forlin@linaro.org>
Subject: [PATCH --mmotm v7 3/3] fault injection: add documentation on MMC IO fault injection
Date: Tue,  9 Aug 2011 13:48:59 +0200
Message-Id: <1312890539-28177-4-git-send-email-per.forlin@linaro.org>
In-Reply-To: <1312890539-28177-1-git-send-email-per.forlin@linaro.org>
References: <1312890539-28177-1-git-send-email-per.forlin@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>, akpm@linux-foundation.org, Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Chris Ball <cjb@laptop.org>
Cc: linux-doc@vger.kernel.org, linux-mmc@vger.kernel.org, linaro-dev@lists.linaro.org, linux-mm@kvack.org, Per Forlin <per.forlin@linaro.org>

Add description on how to enable random fault injection
for MMC IO

Signed-off-by: Per Forlin <per.forlin@linaro.org>
Acked-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 Documentation/fault-injection/fault-injection.txt |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/Documentation/fault-injection/fault-injection.txt b/Documentation/fault-injection/fault-injection.txt
index 82a5d25..10571df 100644
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
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
