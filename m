Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 878E4C282DA
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 13:49:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CAC1218D8
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 13:49:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CAC1218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=decadent.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD0628E0025; Sun,  3 Feb 2019 08:49:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D59E58E001C; Sun,  3 Feb 2019 08:49:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFEF58E0025; Sun,  3 Feb 2019 08:49:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 715CB8E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 08:49:52 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so10110253pfb.17
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 05:49:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-disposition:content-transfer-encoding:mime-version:from:to
         :cc:date:message-id:subject:in-reply-to;
        bh=slUlUfGgvOCkeNTagrRALE+2USqyLZsF0bNhFR31KhU=;
        b=ZQWkNMSiqZ+V/G8d0pFfYju/fyHWuUaiaw0ESZcD1XD3YDszVh3Ox4eauBGFKhPbI3
         +Hv4Q/7EGPgVRwhzeADRHQ+9Nsu5WUCz2fLsYIcXsiPUnE5sdmdB7D1WeaDXW3mR2qEB
         JV/PjW9TxxytpeZXiE00DNJT1W+U2Mfr+Ty1hQ6jzcy8yE1z8jFCNKUIJxKK5TcD7vSD
         Jk3RGONJWeVjC077wDb6+OMNu0okIGS9EjQrevvH8SwmN+d0Vd7VzEQwBKJ6nOt2YFBm
         abD5j0usMd798DaItpX3WbfVtkpcsY2xUA/MiNcO9Pz85AeCailjNSbqfo+o88bB03F8
         67DA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
X-Gm-Message-State: AJcUukfhsX72cWwuO3Xg3WqAJYGbg9JBmtbt5jcdENS/sYOhNR9f6CQf
	0B3BWfFgv4Q2+drFFlR5W+2MWarPbSFZdPQG8Tl9M2BCFO4vJx1qGyjw4JljCs9yAnTRlLDJxcC
	5mPWHVWbKX0qaOS1lWeLslpjgfelcy51z475BAeoXcktRkfIkPdITi51fcrqu3GrAbQ==
X-Received: by 2002:a17:902:1005:: with SMTP id b5mr47907283pla.310.1549201792110;
        Sun, 03 Feb 2019 05:49:52 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6lIR13yxFwm5bim+EuBtinr1DkyciuwduetTSSQgPIaJh6ddtzmGe+rIlHXzOfLvdQQDv4
X-Received: by 2002:a17:902:1005:: with SMTP id b5mr47907250pla.310.1549201791174;
        Sun, 03 Feb 2019 05:49:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549201791; cv=none;
        d=google.com; s=arc-20160816;
        b=Fl/dxDU7F/Ce2B0r61e+gb/v5f8uXrnG0+/6YGh9d7QqroGcBy760eH75UDvk8CGFV
         IITJhVMGiMrNU78EHm1kuX3RBmNbL5w+BbDKSAekUnnRVHI98cDd8K4l5gJExsg/WsSs
         xenAbSVbEJHY6ASM5mEEZZ+3ilQxJwGJRhaEywrFjkTprD9OEnmQPZvgZP4Omw9ShT8n
         u3we6vABX2njTFh3wD+wvazaEXxETNjAD4e0vL5vvCB54ZkWSpcwsRiHiyQSIZV0LDp5
         zdPy+jMzcx0BvgepyPavo6MOdNIn9kKRNzZKYtZOAVjcG5hROvjSM2BgvNgf+n2e7zmR
         GK8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:subject:message-id:date:cc:to:from:mime-version
         :content-transfer-encoding:content-disposition;
        bh=slUlUfGgvOCkeNTagrRALE+2USqyLZsF0bNhFR31KhU=;
        b=dFcQawUZmDEnA45BYrYJmljq2M2ih9lg6x8masPsTsc0vTnAE8jSEZixv7LWO39U3e
         3voVqGJRzI2cQA1LUjEU/WCHkuB+8MPKUuIxd0oIg+ysmK81nAWUS7SbRdnfXrzaRfKO
         JizvXOUWMFnet6fGuoK9H7y38XxRlDFaQFN0k7a8X6/Bag8hoFCNzLwaIzrjcDMLoZaI
         fXgWEvTbVdnHogviGhbUhFtJeL3y9xRYv/8wWWF3piOd2P3obCFL9g4BglDmOzF+vJTY
         bMJmwrhNEVfTIzI//f2/Q75+4NyS9QR8T+NShsXCldU8/LUOw51G3Mh3LoB4rdPwXR79
         zG7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id x186si7750231pfx.269.2019.02.03.05.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Feb 2019 05:49:50 -0800 (PST)
Received-SPF: pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) client-ip=88.96.1.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
Received: from cable-78.29.236.164.coditel.net ([78.29.236.164] helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.89)
	(envelope-from <ben@decadent.org.uk>)
	id 1gqI9T-0003to-Dn; Sun, 03 Feb 2019 13:49:39 +0000
Received: from ben by deadeye with local (Exim 4.92-RC4)
	(envelope-from <ben@decadent.org.uk>)
	id 1gqI9T-0006nI-ES; Sun, 03 Feb 2019 14:49:39 +0100
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
CC: akpm@linux-foundation.org, Denis Kirjanov <kda@linux-powerpc.org>,
 kasan-dev@googlegroups.com,
 "Dave Young" <dyoung@redhat.com>,
 "Andy Lutomirski" <luto@kernel.org>,
 "Arnd Bergmann" <arnd@arndb.de>,
 "Andrey Ryabinin" <aryabinin@virtuozzo.com>,
 "Dmitry Vyukov" <dvyukov@google.com>,
 "Alexander Potapenko" <glider@google.com>,
 "Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
 linux-efi@vger.kernel.org,
 "Jonathan Corbet" <corbet@lwn.net>,
 "Brijesh Singh" <brijesh.singh@amd.com>,
 "Peter Zijlstra" <peterz@infradead.org>,
 "Paolo Bonzini" <pbonzini@redhat.com>,
 "Toshimitsu Kani" <toshi.kani@hpe.com>,
 linux-doc@vger.kernel.org,
 "Borislav Petkov" <bp@alien8.de>,
 "Thomas Gleixner" <tglx@linutronix.de>,
 "Wenkuan Wang" <Wenkuan.Wang@windriver.com>,
 "Tom Lendacky" <thomas.lendacky@amd.com>,
 linux-arch@vger.kernel.org,
 "Rik van Riel" <riel@redhat.com>,
 "Matt Fleming" <matt@codeblueprint.co.uk>,
 "Larry Woodman" <lwoodman@redhat.com>,
 kvm@vger.kernel.org, linux-mm@kvack.org,
 "Ingo Molnar" <mingo@kernel.org>,
 "Linus Torvalds" <torvalds@linux-foundation.org>,
 "Andi Kleen" <ak@linux.intel.com>,
 "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
 "Borislav Petkov" <bp@suse.de>,
 "Michael S. Tsirkin" <mst@redhat.com>,
 "Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?=" <rkrcmar@redhat.com>
Date: Sun, 03 Feb 2019 14:45:08 +0100
Message-ID: <lsq.1549201508.3242952@decadent.org.uk>
X-Mailer: LinuxStableQueue (scripts by bwh)
X-Patchwork-Hint: ignore
Subject: [PATCH 3.16 004/305] x86/mm: Simplify p[g4um]d_page() macros
In-Reply-To: <lsq.1549201507.384106140@decadent.org.uk>
X-SA-Exim-Connect-IP: 78.29.236.164
X-SA-Exim-Mail-From: ben@decadent.org.uk
X-SA-Exim-Scanned: No (on shadbolt.decadent.org.uk); SAEximRunCond expanded to false
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

3.16.63-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Tom Lendacky <thomas.lendacky@amd.com>

commit fd7e315988b784509ba3f1b42f539bd0b1fca9bb upstream.

Create a pgd_pfn() macro similar to the p[4um]d_pfn() macros and then
use the p[g4um]d_pfn() macros in the p[g4um]d_page() macros instead of
duplicating the code.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Borislav Petkov <bp@suse.de>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brijesh Singh <brijesh.singh@amd.com>
Cc: Dave Young <dyoung@redhat.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Larry Woodman <lwoodman@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Toshimitsu Kani <toshi.kani@hpe.com>
Cc: kasan-dev@googlegroups.com
Cc: kvm@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-efi@vger.kernel.org
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/e61eb533a6d0aac941db2723d8aa63ef6b882dee.1500319216.git.thomas.lendacky@amd.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
[Backported to 4.9 stable by AK, suggested by Michael Hocko]
Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Wenkuan Wang <Wenkuan.Wang@windriver.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/x86/include/asm/pgtable.h | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -166,6 +166,11 @@ static inline unsigned long pud_pfn(pud_
 	return (pfn & pud_pfn_mask(pud)) >> PAGE_SHIFT;
 }
 
+static inline unsigned long pgd_pfn(pgd_t pgd)
+{
+	return (pgd_val(pgd) & PTE_PFN_MASK) >> PAGE_SHIFT;
+}
+
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
 
 static inline int pmd_large(pmd_t pte)
@@ -591,8 +596,7 @@ static inline unsigned long pmd_page_vad
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pmd_page(pmd)		\
-	pfn_to_page((pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT)
+#define pmd_page(pmd)	pfn_to_page(pmd_pfn(pmd))
 
 /*
  * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
@@ -665,8 +669,7 @@ static inline unsigned long pud_page_vad
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pud_page(pud)		\
-	pfn_to_page((pud_val(pud) & pud_pfn_mask(pud)) >> PAGE_SHIFT)
+#define pud_page(pud)	pfn_to_page(pud_pfn(pud))
 
 /* Find an entry in the second-level page table.. */
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
@@ -706,7 +709,7 @@ static inline unsigned long pgd_page_vad
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pgd_page(pgd)		pfn_to_page(pgd_val(pgd) >> PAGE_SHIFT)
+#define pgd_page(pgd)		pfn_to_page(pgd_pfn(pgd))
 
 /* to find an entry in a page-table-directory. */
 static inline unsigned long pud_index(unsigned long address)

