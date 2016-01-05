Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id A2D1F800CA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:55:42 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id bx1so254704337obb.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:55:42 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id w188si23491379oib.17.2016.01.05.10.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:55:41 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 11/17] arm/samsung: Change s3c_pm_run_res() to use System RAM type
Date: Tue,  5 Jan 2016 11:54:35 -0700
Message-Id: <1452020081-26534-11-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

Change s3c_pm_run_res() to check with IORESOURCE_SYSTEM_RAM,
instead of strcmp() with "System RAM", to walk through
System RAM ranges in the iomem table.

No functional change is made to the interface.

Cc: linux-samsung-soc@vger.kernel.org
Reviewed-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 arch/arm/plat-samsung/pm-check.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/plat-samsung/pm-check.c b/arch/arm/plat-samsung/pm-check.c
index 04aff2c..70f2f69 100644
--- a/arch/arm/plat-samsung/pm-check.c
+++ b/arch/arm/plat-samsung/pm-check.c
@@ -53,8 +53,8 @@ static void s3c_pm_run_res(struct resource *ptr, run_fn_t fn, u32 *arg)
 		if (ptr->child != NULL)
 			s3c_pm_run_res(ptr->child, fn, arg);
 
-		if ((ptr->flags & IORESOURCE_MEM) &&
-		    strcmp(ptr->name, "System RAM") == 0) {
+		if ((ptr->flags & IORESOURCE_SYSTEM_RAM)
+				== IORESOURCE_SYSTEM_RAM) {
 			S3C_PMDBG("Found system RAM at %08lx..%08lx\n",
 				  (unsigned long)ptr->start,
 				  (unsigned long)ptr->end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
