Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECDE1C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA7A4216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA7A4216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A020A6B0276; Wed,  8 May 2019 10:44:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78CD86B0279; Wed,  8 May 2019 10:44:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56AE86B0277; Wed,  8 May 2019 10:44:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C37C6B0276
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d7so7324733pgc.8
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pNwqrAx4EWfKpCuOStxOcRQu6AVWzjQUQUZ1ejxFi2U=;
        b=VWMTweSdhRaSkNVxNN63GcNoo/RafnI60O/3iJ7R6Mxr+tgLuI3zUl0AL8Fpz+h+U+
         Tzy/f17A2wX9f9PeGr+t2OJsCsH80s7wkwSk3aIvRm7iVGw9UTzUXqk2Y5Myb75odU5F
         gdkytNmCBJQnpJzozVqMVVrAZr1d/z29zDT1U+H+MvJrQPlax74eMCO82dK65M6bxfjw
         n8IysU7qRUyfIR4iYaMqjY3G0LbqzgLsBeKs3oNoVKeb+lIcGKac/GFJrUc5q8+4s3N3
         F93RMz4QNrrHklgaZxnYlqBsv5X2b7lIGe5gx3PTruXN2/ceUxdw0RqHweg5u0hOM4D+
         sebQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVrzJkrrNvhxj73lpWTqBK0Aw/6OxXHssR03f0eyW2Pxzyy82JY
	3uUjw6WIteFIljZSzJ8SAb6XlEvt5srRn2y9N4tbAbM3tHGmMBB8tIy/UaXQuqtcRqFO501bt/v
	x8KFAUlbHI6UCOTV8+VfGXhY8PtFwCdybCEUzYyMCtclsmg6Bhu4XjbwYWos2414yQA==
X-Received: by 2002:a65:6686:: with SMTP id b6mr48090046pgw.419.1557326685708;
        Wed, 08 May 2019 07:44:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWpdOTd40eXzHs3YZfW3tJ+TL4JOg/jtRX3GtBdEbkavjvhu0mLSkOpOqK6IehaS46STeM
X-Received: by 2002:a65:6686:: with SMTP id b6mr48089932pgw.419.1557326684602;
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326684; cv=none;
        d=google.com; s=arc-20160816;
        b=J9ciXUhfx4WD145FOe3BPaGNOIg1IoGu7nLSemyqzH+kmwPZo3iUsfXr3am05jdkEo
         B12F6Qp74rb6OOgsDgnskDPRVF9SwUauBRHBaBi2fhylRZsGk+c09K+YLx+AkwwJCg3e
         acCNfyZEycwO6WxDtjw4BHhJpwlq/sjnjJ7nRYdF3NBdvm5N3TFx8Q9dlT2qH6Unh56U
         55giyUAO49f8+8qMrYAqw2JdEezHudorcZA1J5gMCk1BYgxvZpkVa/wmbZ3TwY4T/GlY
         KHDCYDcCTmND+6EPE3nh49Qcq61xNHNoc9UqjPlBoa1+jTgjqwW3+rFSheo9sh3VqgBx
         0iVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=pNwqrAx4EWfKpCuOStxOcRQu6AVWzjQUQUZ1ejxFi2U=;
        b=AeusQFbW1Fk1Nf0w/jqM21p6Lz5AdSWYWJT/ZUhJHe5SF+fZ8n0Spq2Iu+3y3wJBEr
         3G/qhfTL7u66GF5/jMYWuLZnkmosvxfiZy6SxGIkusUbTilTMgKsXSSRJ58HzMiWVtIU
         vsHNqlFuEKibaTCbbVvSPW5g1uBkarlq9WzKaxIgOjd2ddPLePNbbdY3c06qPPTyXtQ2
         kbNk0aCRmKoOHpZXU3dxrRi0ldtAdmf6tHviYsTl4KVWxSI6LjsOkg5jKep3I1/UpKx4
         8ZfrUmrTPXr+TJUlCU7H6eodBp+qFBXkBLGTLB+NWdsUmF3/moPXSjmPiiz7Jr7cBByO
         JNBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s184si23372828pfs.275.2019.05.08.07.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:44 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga006.jf.intel.com with ESMTP; 08 May 2019 07:44:39 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id A195D9EA; Wed,  8 May 2019 17:44:29 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 19/62] x86/mm: Handle encrypted memory in page_to_virt() and __pa()
Date: Wed,  8 May 2019 17:43:39 +0300
Message-Id: <20190508144422.13171-20-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Per-KeyID direct mappings require changes into how we find the right
virtual address for a page and virt-to-phys address translations.

page_to_virt() definition overwrites default macros provided by
<linux/mm.h>.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/page.h    | 3 +++
 arch/x86/include/asm/page_64.h | 2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index 39af59487d5f..aff30554f38e 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -72,6 +72,9 @@ static inline void copy_user_page(void *to, void *from, unsigned long vaddr,
 extern bool __virt_addr_valid(unsigned long kaddr);
 #define virt_addr_valid(kaddr)	__virt_addr_valid((unsigned long) (kaddr))
 
+#define page_to_virt(x) \
+	(__va(PFN_PHYS(page_to_pfn(x))) + page_keyid(x) * direct_mapping_size)
+
 #endif	/* __ASSEMBLY__ */
 
 #include <asm-generic/memory_model.h>
diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
index f57fc3cc2246..a4f394e3471d 100644
--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -24,7 +24,7 @@ static inline unsigned long __phys_addr_nodebug(unsigned long x)
 	/* use the carry flag to determine if x was < __START_KERNEL_map */
 	x = y + ((x > y) ? phys_base : (__START_KERNEL_map - PAGE_OFFSET));
 
-	return x;
+	return x & direct_mapping_mask;
 }
 
 #ifdef CONFIG_DEBUG_VIRTUAL
-- 
2.20.1

