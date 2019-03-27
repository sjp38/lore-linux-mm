Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC8B5C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:41:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 810AE2054F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:41:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="u+/gcZFO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 810AE2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24F276B0007; Wed, 27 Mar 2019 16:41:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FBEA6B0008; Wed, 27 Mar 2019 16:41:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1124D6B000A; Wed, 27 Mar 2019 16:41:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFDCC6B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 16:41:23 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q12so18197572qtr.3
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:41:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=d+4bMZ8rHzHoWjvzHcDD/tEn1xANDbLdCbbEdrq508Q=;
        b=i+ZyqGjPhZrBXxUAweFkk0b8Mn9g5aROg20pi1/2L6T9PojnQ75bK9OtKRqIfKL9N1
         BxYXYiOZ9mF7Ts/WPX2Iv4AyzRB8NklyOwbWIgmMGLGn1LTFOJ7McZJBl/VsCU6wt+m1
         bpuMaR1xlrCkKrvvO7jtGUchuwJ9PTKTSd5L76+qH0Pdj66DUqZEu6poZ3pNwE01PGyf
         lZaIKSL2hY659thF4FiGdFhtQITp6NZFBAO6ZkHUVtxfOLcIYlRHHQL4SRNzJkUaFsjO
         h+K7PKNNUrqoKT5TApzy/nr5WtgERPBoaAX6mPrlDzoeuOZBV8TwUTRW6Mn6mfPM618n
         eFwQ==
X-Gm-Message-State: APjAAAXd6DAF4akw/0Yk89ozu/d9Klla/lYkvYqFnTLWPDT4Py3xZA9y
	BZ1aOUVgLmVfPN8VkY/ITjc0Yf70SVAyM5tl6yoGz+AbsuZQUop/ub3GM8QyjNbbkkoQn7/4hRs
	cMdHMsOVU1/qx07MLkiRhi7tX46dCOY0PdbYi+yoIl7fTJHMIczcV8LfYYAkhMKNo1w==
X-Received: by 2002:a37:6615:: with SMTP id a21mr30060514qkc.64.1553719283643;
        Wed, 27 Mar 2019 13:41:23 -0700 (PDT)
X-Received: by 2002:a37:6615:: with SMTP id a21mr30060490qkc.64.1553719283068;
        Wed, 27 Mar 2019 13:41:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553719283; cv=none;
        d=google.com; s=arc-20160816;
        b=vamH9ogYE6UGck3usy69vh3LtowksYNSLVqERezCPFszcAJRKY3WvON8pseHD9WyVG
         CL0SQ3gtwoOUZzjP/Z2IAyAVNVEwG34GjNJrrtP3EOKoO9B0yWcw5hM4Jnudip4yz8h6
         PCATQSHqas8gt6STQPuYTJRnQXb+mhlrcOLiYW0RNyCE7hRGPXzDXuppXUEMU02ev1FF
         MOYq8tVr2QczIC8zxOHIqpEu1Cg5epNTBuoVMOyoishD50LjIEzIdBjuBU9wCs4CcTqC
         DEq8DAA8h2dZ3+Jaan2kWVerhKo8127pCs2EMkn3EkmkZsaWaAZlFcjsPUfHRAHJ+/l/
         p5UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=d+4bMZ8rHzHoWjvzHcDD/tEn1xANDbLdCbbEdrq508Q=;
        b=Ur/5n1pCHm+9DzBrPJ7361e6JT3klxjUUSXZqwKSN2Q/TZ+SuZnmQDSiGKsun5J4L7
         PPa7xVy3VKGlJWCcALALaOlQ2rZoI0p1g6/l7njNJBbcpo1beB9sJELiIS17JsLebcgx
         D1X1lAtRxOnQe5e3JhgHM0BuhLFWXRPQ6PV3MsmMDVkazDwS+ZOaUhm62rzBEsy7lQ4g
         0SVCd9uvrGdVNJPXpSveLh201voWtmAbhPyAsLxNL5L03cBFjqR4vw7Jaxo5VZsV4dIw
         iuVzFlzQ7Z35Hmhcv/u9LdbqOgMwCK4+IRINqTL66VSxPEjZtpYgzr4+aj3XGBWHElXc
         VhCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="u+/gcZFO";
       spf=pass (google.com: domain of 38t-bxaukca0wn00ut11tyr.p1zyv07a-zzx8npx.14t@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=38t-bXAUKCA0wn00ut11tyr.p1zyv07A-zzx8npx.14t@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 3sor19583168qth.42.2019.03.27.13.41.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 13:41:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of 38t-bxaukca0wn00ut11tyr.p1zyv07a-zzx8npx.14t@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="u+/gcZFO";
       spf=pass (google.com: domain of 38t-bxaukca0wn00ut11tyr.p1zyv07a-zzx8npx.14t@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=38t-bXAUKCA0wn00ut11tyr.p1zyv07A-zzx8npx.14t@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=d+4bMZ8rHzHoWjvzHcDD/tEn1xANDbLdCbbEdrq508Q=;
        b=u+/gcZFOBRAyKJbEKf7DD4d1TebCZNGNPGFRBc1APR6r2d8gLHkPv7OfRxLn9EuhgX
         TMucWAtP+qQ2EgecTigArAMFMg5LMdiE41SDRnSMXEfqihHW7wqQBg3j+59nhQUaL9MU
         bKc1joU9KQg3gL+rasSnEbsHQQqCX+KaV8EtzJwjW8LYsdmOtM/033zQsvQvO09wY602
         8hubny29J6WF06R+7myO6fwzDAxD3OHubGuP/jbgVOAGBLOOzloCk7gNlDsmtoKT5ILA
         OYK5VonJzeOtV/TH077c25T2SDixr9qw14cXN/+HKZ3lDeJiU43yp1LZBNm7Cvepn+Iw
         5aOA==
X-Google-Smtp-Source: APXvYqxr9sciDPMxjao/0JCNJ9Oxnjqdq+XBKJ4UWjQC34cagq02mzGT4V+V4jMPzz0o/xmi+24YP8Gj6A==
X-Received: by 2002:ac8:22b3:: with SMTP id f48mr1929258qta.38.1553719282754;
 Wed, 27 Mar 2019 13:41:22 -0700 (PDT)
Date: Wed, 27 Mar 2019 21:41:17 +0100
Message-Id: <20190327204117.35215-1-jannh@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [PATCH] mm: fix vm_fault_t cast in VM_FAULT_GET_HINDEX()
From: Jann Horn <jannh@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, jannh@google.com
Cc: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>, 
	Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Rik van Riel <riel@surriel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001082, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Symmetrically to VM_FAULT_SET_HINDEX(), we need a force-cast in
VM_FAULT_GET_HINDEX() to tell sparse that this is intentional.

Sparse complains about the current code when building a kernel with
CONFIG_MEMORY_FAILURE:

arch/x86/mm/fault.c:1058:53: warning: restricted vm_fault_t degrades to
integer

Fixes: 3d3539018d2c ("mm: create the new vm_fault_t type")
Signed-off-by: Jann Horn <jannh@google.com>
---
 include/linux/mm_types.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7eade9132f02..4ef4bbe78a1d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -671,7 +671,7 @@ enum vm_fault_reason {
 
 /* Encode hstate index for a hwpoisoned large page */
 #define VM_FAULT_SET_HINDEX(x) ((__force vm_fault_t)((x) << 16))
-#define VM_FAULT_GET_HINDEX(x) (((x) >> 16) & 0xf)
+#define VM_FAULT_GET_HINDEX(x) (((__force unsigned int)(x) >> 16) & 0xf)
 
 #define VM_FAULT_ERROR (VM_FAULT_OOM | VM_FAULT_SIGBUS |	\
 			VM_FAULT_SIGSEGV | VM_FAULT_HWPOISON |	\
-- 
2.21.0.392.gf8f6787159e-goog

