Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C8D036B003C
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:53:43 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id bj1so14987058pad.16
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:53:43 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ob10si43682489pbb.247.2014.01.02.13.53.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jan 2014 13:53:42 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv3 06/11] arm: use is_vmalloc_addr
Date: Thu,  2 Jan 2014 13:53:24 -0800
Message-Id: <1388699609-18214-7-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>, linux-arm-kernel@lists.infradead.org

is_vmalloc_addr already does the range checking against VMALLOC_START and
VMALLOC_END. Use it.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 arch/arm/mm/iomap.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/iomap.c b/arch/arm/mm/iomap.c
index 4614208..4bf5457 100644
--- a/arch/arm/mm/iomap.c
+++ b/arch/arm/mm/iomap.c
@@ -34,8 +34,7 @@ EXPORT_SYMBOL(pcibios_min_mem);
 
 void pci_iounmap(struct pci_dev *dev, void __iomem *addr)
 {
-	if ((unsigned long)addr >= VMALLOC_START &&
-	    (unsigned long)addr < VMALLOC_END)
+	if (is_vmalloc_addr(addr))
 		iounmap(addr);
 }
 EXPORT_SYMBOL(pci_iounmap);
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
