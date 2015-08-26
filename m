Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id DB8F86B0255
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 04:08:53 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so1133302pac.3
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 01:08:53 -0700 (PDT)
Received: from mgwkm04.jp.fujitsu.com (mgwkm04.jp.fujitsu.com. [202.219.69.171])
        by mx.google.com with ESMTPS id ag4si37214787pbc.247.2015.08.26.01.08.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 01:08:53 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 0BF2DAC008D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 17:08:49 +0900 (JST)
From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 2/3] efi: Change abbreviation of EFI_MEMORY_RUNTIME from "RUN" to "RT"
Date: Thu, 27 Aug 2015 02:11:29 +0900
Message-Id: <1440609089-14787-1-git-send-email-izumi.taku@jp.fujitsu.com>
In-Reply-To: <1440609031-14695-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440609031-14695-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, x86@kernel.org, matt.fleming@intel.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, Taku Izumi <izumi.taku@jp.fujitsu.com>

Now efi_md_typeattr_format() outputs "RUN" if passed EFI memory
descriptor has EFI_MEMORY_RUNTIME attribute. But "RT" is preferer
because it is shorter and clearer.

This patch changes abbreviation of EFI_MEMORY_RUNTIME from "RUN"
to "RT".

Suggested-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/firmware/efi/efi.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 8124078..25b6477 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -594,8 +594,8 @@ char * __init efi_md_typeattr_format(char *buf, size_t size,
 		snprintf(pos, size, "|attr=0x%016llx]",
 			 (unsigned long long)attr);
 	else
-		snprintf(pos, size, "|%3s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
-			 attr & EFI_MEMORY_RUNTIME ? "RUN" : "",
+		snprintf(pos, size, "|%2s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
+			 attr & EFI_MEMORY_RUNTIME ? "RT" : "",
 			 attr & EFI_MEMORY_MORE_RELIABLE ? "MR" : "",
 			 attr & EFI_MEMORY_XP      ? "XP"  : "",
 			 attr & EFI_MEMORY_RP      ? "RP"  : "",
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
