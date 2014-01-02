Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 533EF6B003B
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:53:43 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so14605353pdj.12
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:53:43 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id sw1si43754314pbc.42.2014.01.02.13.53.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jan 2014 13:53:41 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv3 05/11] staging: lustre: Use is_vmalloc_addr
Date: Thu,  2 Jan 2014 13:53:23 -0800
Message-Id: <1388699609-18214-6-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Peng Tao <tao.peng@emc.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: linux-kernel@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>, devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Instead of manually checking the bounds of VMALLOC_START and
VMALLOC_END, just use is_vmalloc_addr. That's what the function
was designed for.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 26b49a2..9364863 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -529,8 +529,7 @@ kiblnd_kvaddr_to_page (unsigned long vaddr)
 {
 	struct page *page;
 
-	if (vaddr >= VMALLOC_START &&
-	    vaddr < VMALLOC_END) {
+	if (is_vmalloc_addr(vaddr)) {
 		page = vmalloc_to_page ((void *)vaddr);
 		LASSERT (page != NULL);
 		return page;
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
