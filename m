Return-Path: <SRS0=NdlI=QR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8153AC282C2
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 22:34:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C82A213F2
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 22:34:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C82A213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF8538E00AA; Sun, 10 Feb 2019 17:34:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA84B8E0002; Sun, 10 Feb 2019 17:34:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBF7A8E00AA; Sun, 10 Feb 2019 17:34:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2BB8E0002
	for <linux-mm@kvack.org>; Sun, 10 Feb 2019 17:34:40 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h15so438408pfj.22
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 14:34:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=C3JT8DoB1yulYYIE3Nc8T8CrrkCjzwNPFcDNpNG9Oyo=;
        b=PUrcGU6pW+kzvswzAIQNwMcTjeUe9OUMS+Vx/t5XwVZ1lORC+XzMQX2XzDkX6s6Rup
         Eqm3K6dXO1/HjWkEMV+LIPaepTTgK7ffytdC0ePwlp3KCMXCDCxcP6ssRAgDCX6EuO6y
         NIltRJMwKJTERjHYf22HIPaq9sZj1lt20vJwiBhyHAWBiSxlmXCdJ8hFhBsM+ofn9Y9P
         +KVtF/e+wnCEluZh3A0oxZjFWSSJZxkpDnsmYWa9S81By0+Tj8yRHcEJPpi8nabM/lkP
         9/G5TtbAHLuoW4nivlO+YPJlKHjF7fN0b0LNF8u3FcBrDogRXjnD8QqZKk16PriLX4Dj
         dtLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY79bLMj2a7uBOITYAkaN8t07VY1681LrGywKiUEkFxDGaWKMUb
	bZm8LrcdgoxKA7CcPMM1ICrCQhUVqZatvAYJnq1ptffUSo6YwtAOy5rl4kkTUFNZcDrychp4syE
	3Vc+sMvJ1cI28oE+FQIw9k75DwkRY7DQi1POn2jiE+ucwxwzjSpHaus4pcYszXqrS6g==
X-Received: by 2002:a65:5003:: with SMTP id f3mr5440491pgo.39.1549838080151;
        Sun, 10 Feb 2019 14:34:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaJS5QRygWsd8NdBwdDzWGY078uM3vmbI6zmrwypFv6Pc3Dj1SnC7fwPMn07ReC7mnr5xXX
X-Received: by 2002:a65:5003:: with SMTP id f3mr5440468pgo.39.1549838079460;
        Sun, 10 Feb 2019 14:34:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549838079; cv=none;
        d=google.com; s=arc-20160816;
        b=inI+dXtv11Prff7lgFmuVsdjb0rtPrcR4l2sC/mFJ+QEM5WKJjdrvA4pWx0zOC1TmJ
         jYkPVkQWwpEoLcqlXjpDpU31+6pgwcW2ExNV+WfCOqenm5lX7tVA8JcAFxIFnzulfJz8
         5fQXHvgDW0T8y/S9QecCDccbeK4ZtdgTDE4UtiAasGz3OJ99pgMdaTApHNW+Q/4KyNra
         vim6YXfP8hgc2LCD2LR/VMjdjMdmxoeG32KBhHMuxC+dUms/C4JwgCFbM9nK6jC9edJ4
         qq8IO0BMzpWUYpXNxOt3+Lc4P6br1vGytnzu8xrGbW1CkoQ1TPec4Obmp24DGBBk/O0L
         4B2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=C3JT8DoB1yulYYIE3Nc8T8CrrkCjzwNPFcDNpNG9Oyo=;
        b=pxnkojREnA9uB6acNmONXffz7KND5sSXwhTqcD7tdI9AgcOjSnXblJfG6jhSdDtn+S
         kY755aEHri77h7GcoxSC6HaRJZTDr80yMrTpNusFYUO9P3AKY9E7rnwrpdngeNL6Fzc8
         fSzk0UaJ0YqWC1I/YYMa2vSMmaowXZmjxhR3tdzScgVqcmzELWpsuIUS8uplCgCH33Ay
         rgWzL+9S0+14Dmu3pHahVOCXokUjPG8lFkChKBuDRWzS3NEHUsZanPRywSx1uzr03OSD
         aqvzFT3QHrfOmQ8u4ZehUo4vePzuQCRX6cUVLmfKPqL4CJSOV3WqvqePoI6JxKq/Hm5u
         TfUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c65si8934998pfe.202.2019.02.10.14.34.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 14:34:39 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Feb 2019 14:34:38 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,356,1544515200"; 
   d="scan'208";a="143135415"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 10 Feb 2019 14:34:38 -0800
From: ira.weiny@intel.com
To: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	x86@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH V2] mm/gup: Remove write argument in gup_fast_permitted()
Date: Sun, 10 Feb 2019 14:34:24 -0800
Message-Id: <20190210223424.13934-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190209173109.9361-1-ira.weiny@intel.com>
References: <20190209173109.9361-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

The write argument is unused in gup_fast_permitted() so remove it.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes since V1
	Clean up commit message

 arch/x86/include/asm/pgtable_64.h | 3 +--
 mm/gup.c                          | 6 +++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 9c85b54bf03c..0bb566315621 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -259,8 +259,7 @@ extern void init_extra_mapping_uc(unsigned long phys, unsigned long size);
 extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
 
 #define gup_fast_permitted gup_fast_permitted
-static inline bool gup_fast_permitted(unsigned long start, int nr_pages,
-		int write)
+static inline bool gup_fast_permitted(unsigned long start, int nr_pages)
 {
 	unsigned long len, end;
 
diff --git a/mm/gup.c b/mm/gup.c
index 05acd7e2eb22..b63e88eca31b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1786,7 +1786,7 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
  * Check if it's allowed to use __get_user_pages_fast() for the range, or
  * we need to fall back to the slow version:
  */
-bool gup_fast_permitted(unsigned long start, int nr_pages, int write)
+bool gup_fast_permitted(unsigned long start, int nr_pages)
 {
 	unsigned long len, end;
 
@@ -1828,7 +1828,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	 * block IPIs that come from THPs splitting.
 	 */
 
-	if (gup_fast_permitted(start, nr_pages, write)) {
+	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_save(flags);
 		gup_pgd_range(start, end, write, pages, &nr);
 		local_irq_restore(flags);
@@ -1870,7 +1870,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return -EFAULT;
 
-	if (gup_fast_permitted(start, nr_pages, write)) {
+	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
 		gup_pgd_range(addr, end, write, pages, &nr);
 		local_irq_enable();
-- 
2.20.1

