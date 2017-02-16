Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60C04680FFB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:45:05 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id g80so27146156pfb.3
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:45:05 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0067.outbound.protection.outlook.com. [104.47.40.67])
        by mx.google.com with ESMTPS id q21si7251694pgi.412.2017.02.16.07.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:45:04 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 13/28] efi: Update efi_mem_type() to return defined
 EFI mem types
Date: Thu, 16 Feb 2017 09:44:57 -0600
Message-ID: <20170216154457.19244.5369.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

Update the efi_mem_type() to return EFI_RESERVED_TYPE instead of a
hardcoded 0.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/platform/efi/efi.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index a15cf81..6407103 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -1037,7 +1037,7 @@ u32 efi_mem_type(unsigned long phys_addr)
 	efi_memory_desc_t *md;
 
 	if (!efi_enabled(EFI_MEMMAP))
-		return 0;
+		return EFI_RESERVED_TYPE;
 
 	for_each_efi_memory_desc(md) {
 		if ((md->phys_addr <= phys_addr) &&
@@ -1045,7 +1045,7 @@ u32 efi_mem_type(unsigned long phys_addr)
 				  (md->num_pages << EFI_PAGE_SHIFT))))
 			return md->type;
 	}
-	return 0;
+	return EFI_RESERVED_TYPE;
 }
 
 static int __init arch_parse_efi_cmdline(char *str)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
