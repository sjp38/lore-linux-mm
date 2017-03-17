Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D88816B038C
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 13:28:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g2so150630597pge.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 10:28:32 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 74si6541515pfi.355.2017.03.17.10.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 10:28:32 -0700 (PDT)
Date: Fri, 17 Mar 2017 20:27:57 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 7/7] x86/mm: Switch to generic get_user_page_fast()
 implementation
Message-ID: <20170317172757.dcfdq7ydqd2yenfg@black.fi.intel.com>
References: <20170316152655.37789-8-kirill.shutemov@linux.intel.com>
 <20170316213906.89528-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170316213906.89528-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 17, 2017 at 12:39:06AM +0300, Kirill A. Shutemov wrote:
> The patch provides all required hooks to match generic
> get_user_pages_fast() behaviour to x86 and switch x86 over.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  v2:
>     - Fix build on non-PAE 32-bit x86;

Fixup for allmodconfig on x86-64:

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index e55fe9475979..e1a0a1fb5971 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -230,13 +230,13 @@ static inline int pud_devmap(pud_t pud)
 {
 	return 0;
 }
+#endif
 
 static inline int pgd_devmap(pgd_t pgd)
 {
 	return 0;
 }
 #endif
-#endif
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 static inline pte_t pte_set_flags(pte_t pte, pteval_t set)
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
