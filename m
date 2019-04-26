Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32054C43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDC48208C2
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pYvgo9ZC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDC48208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2F986B0275; Sat, 27 Apr 2019 02:43:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37AD26B0276; Sat, 27 Apr 2019 02:43:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21CF86B0277; Sat, 27 Apr 2019 02:43:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAA086B0275
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:34 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f7so3576051pfd.7
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=RIE66crRSFais2XMEreovT7cuc4aWzwk2c6XjFrsy1k=;
        b=MfbnEr5+Io6aAcv/6wwHi8fgB607akDoT/l1A4tDl1QE9gu+jO2BP1JWbQAc1pS1Ad
         3DXZsdwkAQtFznpM3LXG4Qfu7Ms3qUy4tw9ugY0vvUcgzjErisYOj7u+CFbEamYsqdis
         OxDh/tYmnZp5ORHy7Zgk4P8/Hmuu0H+IObvKKxJfBZ3DBpnNzmzYJ4kImI8gZ5glptp5
         ZUNDNW7ZlfxePZObFjBF5vD2ds/8PEEMFa5gBYDuOoISaOg3b5cwEcwlCISrtV2Ehtvw
         jGA7mCnUYwOdWUfrH8+JYwT3HhHHizOOtAcKhpPrYlT7KEDlw+l7DJMcPKAo1OFhYY22
         QOZg==
X-Gm-Message-State: APjAAAWCleKUVAdPJLR4apulNVQYBt+GXz9fztHMsoqzZ45KL4Ul7QJe
	8H0HyDlZcAuyfg3ELVg15bWm4/lC/c+PpwYzf35k6ZZ/HqPD7Guv12PDgpZeq5bk80BNhsFjEx+
	N6f3EwfyK6rnsPDbQ/S0wJloMC7MnJ3bRyS6kLcmkPcknvsPrV6UOcque1PJ5ame0QA==
X-Received: by 2002:a63:da4e:: with SMTP id l14mr44930396pgj.96.1556347414583;
        Fri, 26 Apr 2019 23:43:34 -0700 (PDT)
X-Received: by 2002:a63:da4e:: with SMTP id l14mr44930347pgj.96.1556347413480;
        Fri, 26 Apr 2019 23:43:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347413; cv=none;
        d=google.com; s=arc-20160816;
        b=POkuA9qrg1gzRhiLi+Wkey+bx7atI4fYoWDTs7XJuOapyabq32FeKr/ztm4MUXW9BO
         Gu+w+xo+nW5kyPQpY7JuauoJ8UI127W6InyjgT09C7VAd4FcZ/Zn6roSYehEvluqxf5j
         IZGIL5eJ/jX9AsjQS0nl5Qf9L2+C0E9/tA3kh/CGgFhEhkiwR5Q6SkKW/HCnMrJ8r+6s
         oKfYCCYIUlYHaXV/iC77PcUrHuvTYBHueEShCex9gtIiqc92SxuQI2KW0mRI+HlxlJfC
         Ydpm1mv4If+v44FW15w97Qf/fItmQ6i4Il78LLQ4bMA6XymXED/iI4lZx1HJdXc3YzOw
         nLlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=RIE66crRSFais2XMEreovT7cuc4aWzwk2c6XjFrsy1k=;
        b=F9TDqMkMosgp1YxLckGEARbcEHdLrLTZDXzG90TZAnkMYBAYjtULLsZYSmnsaiWvSc
         T/dAv2Pcz+t59Uw0nQR48j9zTWXLYadwxYYwsQ56ZTFBoLP21SkwAECi8z6a72s0ax2r
         gJQ0udD3pWMNv0KtYfe6tNuVrlHeoY1CORcvck1WptVcdArSHAfjtHzQ5I8kchFf7Xll
         aPIPvbjWQ5bXlqwo6+2RiJVURCeDR/6pD/556KZU/vkH/66t0ki55/jrul8aFvZQrpme
         OpzdaEUilbLDWoLgVKgENfXIR5kUSk7Xe3XoXPJkyJPzR9uwk1tzFdTKDddKDT8uRFth
         c/vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pYvgo9ZC;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor27052107plq.14.2019.04.26.23.43.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pYvgo9ZC;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=RIE66crRSFais2XMEreovT7cuc4aWzwk2c6XjFrsy1k=;
        b=pYvgo9ZCfUCHvRHlTxheTL9ZRQVp4fim5mJ1MwWcKR1lA8y1aUP/jaFmmW0gvaWJ7S
         zVzA0PQ2EURS5SWk/peFTu1A3/0LRw7DZYQoG4uzOziiwhPRGPxHOWrU2FLz8xJKPBlh
         /zuS4kFNlrBUqnzlR10WasNuwWxPh6kwUkYfWX2HNs3YXw+waJ/qMVcWCQyEr/PXxH6M
         ipIVs/0XiprUGYbGWdjj/stD10SwODP6rYxbEpQWhHBNTSo8/W1+lQ5k//iDxItfsPxn
         hO3NCZNloR7//+m6Eozd9KTmliFtML7SM01N4FLmt+HleGXZ2gYxUmzOYvSuD2G1W0Lp
         NyOQ==
X-Google-Smtp-Source: APXvYqwLfbRywYDBLBkn2s5QjOy7Ake8UGyhjw6r9cFTnOHwE2KsORvL/Fy4JLKSQeWsUj9Okam5Jg==
X-Received: by 2002:a17:902:b68e:: with SMTP id c14mr52282678pls.49.1556347412993;
        Fri, 26 Apr 2019 23:43:32 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:32 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v6 20/24] x86/ftrace: Use vmalloc special flag
Date: Fri, 26 Apr 2019 16:22:59 -0700
Message-Id: <20190426232303.28381-21-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rick Edgecombe <rick.p.edgecombe@intel.com>

Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set NX
and RW before freeing which is no longer needed.

Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Tested-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/ftrace.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index 53ba1aa3a01f..0caf8122d680 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -678,12 +678,8 @@ static inline void *alloc_tramp(unsigned long size)
 {
 	return module_alloc(size);
 }
-static inline void tramp_free(void *tramp, int size)
+static inline void tramp_free(void *tramp)
 {
-	int npages = PAGE_ALIGN(size) >> PAGE_SHIFT;
-
-	set_memory_nx((unsigned long)tramp, npages);
-	set_memory_rw((unsigned long)tramp, npages);
 	module_memfree(tramp);
 }
 #else
@@ -692,7 +688,7 @@ static inline void *alloc_tramp(unsigned long size)
 {
 	return NULL;
 }
-static inline void tramp_free(void *tramp, int size) { }
+static inline void tramp_free(void *tramp) { }
 #endif
 
 /* Defined as markers to the end of the ftrace default trampolines */
@@ -808,6 +804,8 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	/* ALLOC_TRAMP flags lets us know we created it */
 	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
 
+	set_vm_flush_reset_perms(trampoline);
+
 	/*
 	 * Module allocation needs to be completed by making the page
 	 * executable. The page is still writable, which is a security hazard,
@@ -816,7 +814,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	set_memory_x((unsigned long)trampoline, npages);
 	return (unsigned long)trampoline;
 fail:
-	tramp_free(trampoline, *tramp_size);
+	tramp_free(trampoline);
 	return 0;
 }
 
@@ -947,7 +945,7 @@ void arch_ftrace_trampoline_free(struct ftrace_ops *ops)
 	if (!ops || !(ops->flags & FTRACE_OPS_FL_ALLOC_TRAMP))
 		return;
 
-	tramp_free((void *)ops->trampoline, ops->trampoline_size);
+	tramp_free((void *)ops->trampoline);
 	ops->trampoline = 0;
 }
 
-- 
2.17.1

