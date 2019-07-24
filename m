Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3517FC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:08:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05C4F22387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:08:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05C4F22387
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABF086B0003; Wed, 24 Jul 2019 02:08:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6FE38E0003; Wed, 24 Jul 2019 02:08:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 960A18E0002; Wed, 24 Jul 2019 02:08:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 469426B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:08:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so29606688edb.1
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:08:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yu1rRm8vVlWs2k5HxuFICi9Y4uSbUPRh8t0lFYmfJhM=;
        b=VgNs4g5H+1wTZFIi2kvu+Kfm6Ec5V9lWBCW4D0NqfWieQEG+iIWJfeWVLXTj5055w4
         Tr/+w+HQbb5ntC/UjO0HJm0mN7Ziuu8TczwHIVXm6f+1Z8Fts+765DNBAhxZhamMZz18
         18rq4jABnbbf/njSU/UBweoW1A3g/lhFmOleAL+9X1VxHzMf+9EhE5rILdskvmv7/S+V
         9B/2TLn1vnYTvNy1vXJXodqi1/33TK5x7xkhBoItUPOyfF7+EbRXwCOJMiPEhliRZc65
         8NzDTvgyNZNgSeHQq7gu1BUCrAZisBKukhqLLaFa4vapqEyPbTb+MNdD7YZ+0Km38xPG
         0c5w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUe/oe+O/abh4f40agp689BsYZKRkF6WQTJKZKeJ2XtuQIuLgbL
	ATK3dzLPTJtWKWdNOEGc/G9Zbm40x482peoy38IxgtsRPMyVl+P6rU3I13tk35hAEt41tAbjXay
	PTxNe2X43k5CTdAiSBLB1HoQ/mO9Kn6bwRq8/CZgEoNblL3nClshpObvxC1MSCx8=
X-Received: by 2002:a17:906:4b13:: with SMTP id y19mr61001484eju.145.1563948533871;
        Tue, 23 Jul 2019 23:08:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhRscGGM/7WKzsJ5uP3AfYRfFtwPVF2r5uvhO9IiHfPNY0bojRsBKa82r8+v3Dh9JT/XBv
X-Received: by 2002:a17:906:4b13:: with SMTP id y19mr61001447eju.145.1563948532976;
        Tue, 23 Jul 2019 23:08:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948532; cv=none;
        d=google.com; s=arc-20160816;
        b=Z5hcVAVT2nQDYzRg/8YDO5LctGIDw/B/ulqzGF0kgTkweN4rwnWLCoz2lqY3FCNczw
         j0UsDCJJR4Z+ncK7G6OToVphBMB3/LLs1jVq3wSoug6kSAjNOM63H3YfHTwNttY1yz0N
         F7XHmuaJSS9rIkNtP6cwQ9QHnskSiylDAReCSsSJtIDEBL6n0KnlGZ3R397UwG6NLAHV
         Ml4i8RFsver1Q7IsT9lN/NyzhJqlRWDR25T/09kRydKUe309Oqxv51nuOTP/F5YmTBdY
         m5KB9/KUiA/chDHNOGcTfd2ZtFZY38CcrgwqhWF9j4yAmy4/H3JuUA7vvBCqPVSC9T00
         Ue0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yu1rRm8vVlWs2k5HxuFICi9Y4uSbUPRh8t0lFYmfJhM=;
        b=HpLBMtValQoTWMHlJqOYBAczKcOaRX8mF+ZyNI+O4DSoWHq/scgvRe4XkkPOlcrLOD
         l/oS+ewXrPQTIYpY+0Wk3BceCH7hte5Dg/G/sQroHfj7rGK5OaGiv84HJbBginD3yaNh
         M31ch+68hhbh1s6cD+h2ssu9SE4QYyI3p+jKDcB0ie4JUhAjnslFiLT3pY2c6/l8kRo0
         VvUILLpnTLVdvwqEGpzibeZZi3rgKCOAndMHXLQo2v0skSwPeubpjoNs+VBCZMA4cddc
         s6uM/gSRlWUY08CdbZrYu7Ba4fT+XwYBZQBp2fW+8TXbFHAcVxfBKXeb7TCAlEQfLOQq
         oCIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id q44si7634788eda.375.2019.07.23.23.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:08:52 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 59E6560008;
	Wed, 24 Jul 2019 06:08:48 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH REBASE v4 09/14] mips: Properly account for stack randomization and stack guard gap
Date: Wed, 24 Jul 2019 01:58:45 -0400
Message-Id: <20190724055850.6232-10-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724055850.6232-1-alex@ghiti.fr>
References: <20190724055850.6232-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit takes care of stack randomization and stack guard gap when
computing mmap base address and checks if the task asked for randomization.
This fixes the problem uncovered and not fixed for arm here:
https://lkml.kernel.org/r/20170622200033.25714-1-riel@redhat.com

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Acked-by: Paul Burton <paul.burton@mips.com>
---
 arch/mips/mm/mmap.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index d79f2b432318..f5c778113384 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -21,8 +21,9 @@ unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
 
 /* gap between mmap and stack */
-#define MIN_GAP (128*1024*1024UL)
-#define MAX_GAP ((TASK_SIZE)/6*5)
+#define MIN_GAP		(128*1024*1024UL)
+#define MAX_GAP		((TASK_SIZE)/6*5)
+#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
@@ -38,6 +39,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
 static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
 	unsigned long gap = rlim_stack->rlim_cur;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
+
+	/* Values close to RLIM_INFINITY can overflow. */
+	if (gap + pad > gap)
+		gap += pad;
 
 	if (gap < MIN_GAP)
 		gap = MIN_GAP;
-- 
2.20.1

