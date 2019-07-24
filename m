Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BBEAC41517
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:09:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C79F22387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:09:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C79F22387
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABE686B0003; Wed, 24 Jul 2019 02:09:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6F618E0003; Wed, 24 Jul 2019 02:09:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 985918E0002; Wed, 24 Jul 2019 02:09:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3406B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:09:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n3so29542686edr.8
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:09:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LxxYxWqxNkL+rNpCPJA+2SpcBDfwJZpToQa21YnSig8=;
        b=JhRc2AY7Z9B0A6CK/ryBI9IpuapFYPOgZ4AC0bVVV7USsFMLXyV/RhHs6nbi7kjt6v
         svm0BzU94QtoK80jwPG1PtbI4fJpCvRTmDkp/NHXNYjc76z54k8TxxJvuIT4losuUirh
         gCjS0tObMf5mZuXwCwRtFKmeXJMOXiYAfQfBngx0K/GZNgWKWPtKFwr7Z+Bm4ykV9TMr
         Zoyt1SNIDZyXLaL7FXmkDwJdefhOHWFfBH7ogy6jwq7aOyaHCQrRSSfLTbFTUTa09o0K
         fThGDCQio4QwTZghiMPotvw5l935uw1YWEvF0Smd/GmuCRxvtZTQcmdNOtMDN0mpU24l
         113Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVnvVveX8PrTSc9Ku+4W00FgREWrCY+htwqjdDNY+6MEOZ3hMZC
	LaasM5wdxUlcXqVjzVx/hI04FWiiwmD3p5QTef0xO4SRO3ZMXpWEEYuA2MLiAS63TUlEztrGRnR
	4KBcdv2SZewa5No3t9lVarsehG5BvQHtwq5vgKBLOAHEB2/SdwCmuQD03w8rVufE=
X-Received: by 2002:aa7:cd17:: with SMTP id b23mr70146462edw.278.1563948597898;
        Tue, 23 Jul 2019 23:09:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJu+1BgmWhl+DtWybZigvpQLF3Pxdwwj/eKFurkL9URFzqqeZYNqjsfJ7KLCT/jeuWOMse
X-Received: by 2002:aa7:cd17:: with SMTP id b23mr70146426edw.278.1563948597005;
        Tue, 23 Jul 2019 23:09:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948597; cv=none;
        d=google.com; s=arc-20160816;
        b=EjMFwcc+OG/Rj79652qs+2dUGT5E77oUVf9vxqGdhnaV/ZnSJ+8EMtz/TrcXWrjHHv
         Rdl7hJcPGn5psm7JJjC8NCPRykOuyAho8hmMcxvUslNVUsLZloMq0DQpbBGF4fKF0BXM
         OXERc6n4t5VcuUfOqirwrhEPaLEB/hlL7yWrnpqmRC1lYNDMhqiiAuOfxvJKXuFi+n6A
         eVvaRwPBXggc7YJoHLKeOmfJHWpk/ue9pTdvssINjMn0SbvN1sjPbQXe5Sc4583mDTpx
         PIk+JtNYw8UC0wEEjV2foZw3QOt9h6XWTcVAERszTOSDG38PTRwsyYUPG2lNxTOCGORZ
         4SmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LxxYxWqxNkL+rNpCPJA+2SpcBDfwJZpToQa21YnSig8=;
        b=wZU4cU3GGMYGJQFAA9shb8ybhd5buzUXWuWVDO40rdwh7PSx9b9mH1fUUtcgURxquT
         64tScXpC//fzd9+g4razXIeTsG/+smTz4C8U9O7L/7IDrY74vzQO1gsgzSPed1fB3Slw
         dapf6MYxcejiLMWyzuMGdhcQkczUctU6gr8EBiN9QOnBJZbKh1Yg9utVRwK//I9r9tXX
         mSqfSJ8lO2wr7Z0p2qm7n/CQG4gHuHwdutuxHKEpyt3fLLQyORpszreyQ1j+jCqUcA17
         RKRTpejIX138arENGTNOp0Cc7EXJkt2e3S2EAr2Hx6rEmZlY9orbpAEJyGOYuLk3YVeq
         oEeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id b36si8041886edd.79.2019.07.23.23.09.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:09:56 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 226A060008;
	Wed, 24 Jul 2019 06:09:52 +0000 (UTC)
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
Subject: [PATCH REBASE v4 10/14] mips: Use STACK_TOP when computing mmap base address
Date: Wed, 24 Jul 2019 01:58:46 -0400
Message-Id: <20190724055850.6232-11-alex@ghiti.fr>
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

mmap base address must be computed wrt stack top address, using TASK_SIZE
is wrong since STACK_TOP and TASK_SIZE are not equivalent.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Acked-by: Paul Burton <paul.burton@mips.com>
---
 arch/mips/mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index f5c778113384..a7e84b2e71d7 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -22,7 +22,7 @@ EXPORT_SYMBOL(shm_align_mask);
 
 /* gap between mmap and stack */
 #define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((TASK_SIZE)/6*5)
+#define MAX_GAP		((STACK_TOP)/6*5)
 #define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
@@ -54,7 +54,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
 }
 
 #define COLOUR_ALIGN(addr, pgoff)				\
-- 
2.20.1

