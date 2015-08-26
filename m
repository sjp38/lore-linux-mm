Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC8C6B0254
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 04:08:44 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so152862010pac.2
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 01:08:44 -0700 (PDT)
Received: from mgwym03.jp.fujitsu.com (mgwym03.jp.fujitsu.com. [211.128.242.42])
        by mx.google.com with ESMTPS id ho6si37321255pac.147.2015.08.26.01.08.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 01:08:43 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id CEEF6AC03E3
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 17:08:39 +0900 (JST)
From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 1/3] efi: Add EFI_MEMORY_MORE_RELIABLE support to efi_md_typeattr_format()
Date: Thu, 27 Aug 2015 02:11:19 +0900
Message-Id: <1440609079-14746-1-git-send-email-izumi.taku@jp.fujitsu.com>
In-Reply-To: <1440609031-14695-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440609031-14695-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, x86@kernel.org, matt.fleming@intel.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, Taku Izumi <izumi.taku@jp.fujitsu.com>

UEFI spec 2.5 introduces new Memory Attribute Definition named
EFI_MEMORY_MORE_RELIABLE. This patch adds this new attribute
support to efi_md_typeattr_format().

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/firmware/efi/efi.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index d6144e3..8124078 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -589,12 +589,14 @@ char * __init efi_md_typeattr_format(char *buf, size_t size,
 	attr = md->attribute;
 	if (attr & ~(EFI_MEMORY_UC | EFI_MEMORY_WC | EFI_MEMORY_WT |
 		     EFI_MEMORY_WB | EFI_MEMORY_UCE | EFI_MEMORY_WP |
-		     EFI_MEMORY_RP | EFI_MEMORY_XP | EFI_MEMORY_RUNTIME))
+		     EFI_MEMORY_RP | EFI_MEMORY_XP | EFI_MEMORY_RUNTIME |
+		     EFI_MEMORY_MORE_RELIABLE))
 		snprintf(pos, size, "|attr=0x%016llx]",
 			 (unsigned long long)attr);
 	else
-		snprintf(pos, size, "|%3s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
+		snprintf(pos, size, "|%3s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
 			 attr & EFI_MEMORY_RUNTIME ? "RUN" : "",
+			 attr & EFI_MEMORY_MORE_RELIABLE ? "MR" : "",
 			 attr & EFI_MEMORY_XP      ? "XP"  : "",
 			 attr & EFI_MEMORY_RP      ? "RP"  : "",
 			 attr & EFI_MEMORY_WP      ? "WP"  : "",
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
