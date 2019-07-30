Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32101C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:04:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB5852087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:04:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB5852087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91AEE8E0018; Tue, 30 Jul 2019 02:04:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CB0C8E0003; Tue, 30 Jul 2019 02:04:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 793AA8E0018; Tue, 30 Jul 2019 02:04:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2A18E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:04:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so39640388eds.14
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 23:04:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=juJS37x5CM43D+6DWMHhdR9jUChuu/SEXc2RnrYUv1M=;
        b=oHNlbyq1gAzkw7JHoRfmzJuJ5RLcTcPd3gLl/ihJ5246HAwkncaEscD+foyj/L416X
         oHf/GOA550JrI1VRpvYPHKZtlOvlpwXJLvcdq0VGNPjNO5Qi8jJP1//ljnEtJav+jc8L
         2dSjw39T2u+SnLPrLkA+gpp3xljKbNYD1azVTyIjFhy0lddKGII8IYRb0JQ45+v9hicP
         HlWfR1KUKXy2TSRJkhhaqpmf9oOdV1bpSx294bbyd7AFmC293K1wRNCy6bHcDGBudekv
         x3vAcGtc+5Mt9OSFAvr5xazbnVo/xMXfM3t0jhj6M2/8bmhb8vocAdA/wGBrgeZu/d+3
         CkQA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWmgpH41T6NfZtRAM/O+IIKIElyLiqgKouO0ibnn/5raOi90rK2
	JugrFgvD9Y7RnhR5aOlngGQd7NAT5940ZBW5r6AyF4tI8dLlEeph4KtWBL7yioiVcWXKNEC9bil
	02ruMxLy0b4D+xujz9phIIN/iDc/OVBI7R9ggAcQEZE+TgWGgScqGTZa1YLgI3Mc=
X-Received: by 2002:a17:906:3f87:: with SMTP id b7mr86029243ejj.164.1564466672769;
        Mon, 29 Jul 2019 23:04:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykgwUdWoOkMMckGUufP50sRByCnf38dgCxOM1AI5H6tK/36MvMDX1zvTs+mh8U519xN7hk
X-Received: by 2002:a17:906:3f87:: with SMTP id b7mr86029188ejj.164.1564466671974;
        Mon, 29 Jul 2019 23:04:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466671; cv=none;
        d=google.com; s=arc-20160816;
        b=IwLtFFJvPalaFOrl+rbqnKXEGfWt0OtGfOQEq/SgAO6TARtOw5Jj1ndnODy5zJ0tWe
         mfcxeHf+Y5S9jYObo6oMMK6hE8TnWyRwG5tlb+DqTsjYFDCjnbF/54W+iWEmwakq6E/V
         x/pUc5nBZEY3mVFnyOk9N+yb9XQE4zdGrxKuhyrT+S54wXeEMJ6n9VHu0GbiyrtmrHla
         ZAIJ5BEfiMpsTw1hpAtQHlH4OVzro9MtIKJhAokfoMFmsbCcSBk71dLpVs9zAYL2Sq9h
         fePuN3R704KRVJ/AxwQlFyQq40eW534MR6YPCMUS1TecW4GW2OJHIU6WyMbHxLw8UvzX
         4hQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=juJS37x5CM43D+6DWMHhdR9jUChuu/SEXc2RnrYUv1M=;
        b=nfmhMKrgJAi+FsFA+vWuFyYijP/IULmnk4a3+CcLtcXoYx5huppjjmfCVAL/AbjTwG
         zanGaUu2tcFfWmiZrixQ9TQdpSFoDLLHAHQFnVxzshQNLEBAacs01NWOOiT/XBWuYW4N
         lg5zjRgrBWRFvksF3wyVusEkz9QdjTnZ/x2+myBEjye5+5AGh4I8C8qKBijjxeI+1ybe
         ZPhT7oSO/MN2JqEqPSQn1o77qv3y22PAG0EI5M1PoKnCPpQqAcCGp8CWxsYju+Waj5sg
         3jWAnd+ma2JT8fci2idGHCLMtO+4MI6R+45kmNVljyWNfPJPf/yrWve26z3CEKcZuF0C
         iTsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id m17si15753741ejz.352.2019.07.29.23.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 23:04:31 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 94A64E0005;
	Tue, 30 Jul 2019 06:04:26 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v5 12/14] mips: Replace arch specific way to determine 32bit task with generic version
Date: Tue, 30 Jul 2019 01:51:11 -0400
Message-Id: <20190730055113.23635-13-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mips uses TASK_IS_32BIT_ADDR to determine if a task is 32bit, but
this define is mips specific and other arches do not have it: instead,
use !IS_ENABLED(CONFIG_64BIT) || is_compat_task() condition.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Paul Burton <paul.burton@mips.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/mips/mm/mmap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index ff6ab87e9c56..d5106c26ac6a 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -17,6 +17,7 @@
 #include <linux/sched/signal.h>
 #include <linux/sched/mm.h>
 #include <linux/sizes.h>
+#include <linux/compat.h>
 
 unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
@@ -191,7 +192,7 @@ static inline unsigned long brk_rnd(void)
 
 	rnd = rnd << PAGE_SHIFT;
 	/* 32MB for 32bit, 1GB for 64bit */
-	if (TASK_IS_32BIT_ADDR)
+	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
 		rnd = rnd & (SZ_32M - 1);
 	else
 		rnd = rnd & (SZ_1G - 1);
-- 
2.20.1

