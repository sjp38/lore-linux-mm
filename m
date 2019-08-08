Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD303C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:31:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA0EA2184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:31:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA0EA2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 478AD6B0006; Thu,  8 Aug 2019 02:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4029E6B000C; Thu,  8 Aug 2019 02:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CAF26B000D; Thu,  8 Aug 2019 02:31:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CF4306B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:31:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x40so535245edm.4
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:31:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=juJS37x5CM43D+6DWMHhdR9jUChuu/SEXc2RnrYUv1M=;
        b=Owgm3gCivKt74jip65Q5URxxxt9jmVrRxjceUR/ZZzhUup973BZ7yxBuosBVjXIgLm
         It4SJxl4B7gRgtMrEzzOyL4gAxUTljredIRhgwKpCqFHpMsVsqn3zSbeQsMs7h2BwX44
         d+pRl7vdM6kW+Z+veZmD/iaoxBVDNMgQRrTOPQTTkT8h3f/cUUXXCki9pfhJd2LO2Uv+
         kZfnfS6n8BFw13IsG8DScGeZ6sFSmddqqyoSseovAL6iGjL0tdKkN09ecKh1ryoSWASV
         476ZZCeODwEQ5OOhOtpi0Z6uerRe9/nUoktb0ZfB0yslfFpAeNUi2MXRMl09A8vjWTTJ
         4e1w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUFjamobsypoZVtwxnpxXxU/EpQKEVE12cxEHA1x0XB2jvgk6Yl
	hYaDr5jd9cOikBO9fsFsJhC0NAT0xrGHXdOzYhtCDjZEyLXZZAr87R90wsX0m3AqvyGrsdLndPk
	mi8wJ9Ca0bNEP8J+2r0Lmfs0Fi+jJxJxMY+v5JHx11I0o3RlMG+YWKvpTyRithd4=
X-Received: by 2002:a50:b13b:: with SMTP id k56mr14398567edd.192.1565245876414;
        Wed, 07 Aug 2019 23:31:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCaEQD9Lk8QaDUjJZ3b6y/J1zEVsfEmfDlI03n/7MmmTCYcEeCv4SnKSq5AR4VaS7AEyEM
X-Received: by 2002:a50:b13b:: with SMTP id k56mr14398479edd.192.1565245874747;
        Wed, 07 Aug 2019 23:31:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245874; cv=none;
        d=google.com; s=arc-20160816;
        b=w0OdGiTbG5AuJmZop9xaQYIPjhYmG/gMgxQ2nuokNrJATLAGsJheEV81MVx1n6VPhd
         S/d3UuHd8MWJdz2UjSAIrQmo3Z39Q9D63Wz8EHFlcA1YCVrsu07Uf5tbh6obC0S+LsZo
         YAreX+fAvsPPe9ttDHQ9h6jaiqasQvrqUUuWDtTeI20wizSufS21zCBtf8fxRjIODg0k
         OoafXT3G31on1+1qHlx1+FfCLjyQxQx7JN4S+AF3s3vPSv+TfgA/ai2u0E09MsmrWJw+
         /pxVAj1b4o8Zv4xgsYliE2uFsHelrrujWfNWxrExdZYY/juaLWVbNw42RIWluowoeCB1
         YX9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=juJS37x5CM43D+6DWMHhdR9jUChuu/SEXc2RnrYUv1M=;
        b=hOXlhROt9w0kkPeUGYTtYTRW0Pqcpj6YkV01bZwOuOx3MMbVnJJrarmX+uIirQwhhh
         r5YYx1kG7BBqkrC4vog7hLdUPVQnBUWdQZvG2l0VaNj1TgxCR8LMEuj1PRd1G7+oqqjy
         u+hXF3J+mOjsJLowXbEje91DUrFxElhQ26s4Pqo1uqL8QKDfIP7sxu7ytAKuHsQI82nt
         6xZCabs1+8xXYYgu5hBVCjP6FsOGManxvzgyO1RmsFJe+Zy7qMKpXt7dIbQNyvqfXCc+
         1VlQTSboalk292doIZGGKhjZco6H7jKSzAj48sONxnhYwyc5SyRL4lg7qEuYFd/0zu0G
         BE2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id 5si1065909edz.413.2019.08.07.23.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:31:14 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 60503FF802;
	Thu,  8 Aug 2019 06:31:07 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
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
Subject: [PATCH v6 12/14] mips: Replace arch specific way to determine 32bit task with generic version
Date: Thu,  8 Aug 2019 02:17:54 -0400
Message-Id: <20190808061756.19712-13-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
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

