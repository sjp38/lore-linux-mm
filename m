Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 61B586B0036
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:53:41 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so14531678pdi.24
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:53:41 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id xu6si6175903pab.341.2014.01.02.13.53.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jan 2014 13:53:40 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv3 01/11] mce: acpi/apei: Use get_vm_area directly
Date: Thu,  2 Jan 2014 13:53:19 -0800
Message-Id: <1388699609-18214-2-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linux-kernel@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>, linux-acpi@vger.kernel.org

There's no need to use VMALLOC_START and VMALLOC_END with
__get_vm_area when get_vm_area does the exact same thing.
Convert over.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 drivers/acpi/apei/ghes.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index a30bc31..6e784b7 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -149,8 +149,8 @@ static atomic_t ghes_estatus_cache_alloced;
 
 static int ghes_ioremap_init(void)
 {
-	ghes_ioremap_area = __get_vm_area(PAGE_SIZE * GHES_IOREMAP_PAGES,
-		VM_IOREMAP, VMALLOC_START, VMALLOC_END);
+	ghes_ioremap_area = get_vm_area(PAGE_SIZE * GHES_IOREMAP_PAGES,
+		VM_IOREMAP);
 	if (!ghes_ioremap_area) {
 		pr_err(GHES_PFX "Failed to allocate virtual memory area for atomic ioremap.\n");
 		return -ENOMEM;
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
