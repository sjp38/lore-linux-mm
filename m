Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB120C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:32:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83D5C217D4
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:32:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83D5C217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28E6D6B0008; Wed, 17 Apr 2019 01:32:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 265756B0266; Wed, 17 Apr 2019 01:32:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17B476B0269; Wed, 17 Apr 2019 01:32:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2BE16B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:32:43 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h10so4056454edn.22
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:32:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6D+bml0GAKMUKHe87npe+2LGj2+9T7+GwcJmjpz0elM=;
        b=avxJDEKVgoviBboW74xj9KkOFcMlXOlHOlsYHQexHEkyp4XLEOPCKCMnBQY2secwCg
         SYvDTc9VMqxt6qLttkfqpnmaXIeC/Wxi/XjqgVWPE3rUFRh4JgxOdSjgn/E2TWuuTyJ7
         /u6Po7upVG4U+ZRJJgOj/99X2/+B6T1J+Dz6bbHBYHgG/4wodmFx8gyK+6Wckwg8qxE9
         7FMuPAWyBhOu/k9uxqMASrfJkhVUAYjaL1LCttKISOmabCliAS0cO3FTCT4dQhYS8Qfd
         sSEi1+LBetdxXa5WzCKC7A2hUO8wIVJcmb4fgKLHnjNiGpo5tvtBglwbpuXZjUF3dWjY
         r02Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUnyhA/xzJIh71YqK+7V5+BXIJLCzfNeED5wD6m+mazLIWRy7Gr
	fKxwgdMt4zWR55q9QmW3OA9pG8GJ+Ws9whZXRwna0KV91jRhI9NAD0Dk4+KV/pf5VTNEFepG6Y4
	yF7wjd2i16Pd/Ofx0RcirQqMTFfxhcACgGEQeTkwidfGiXsO3Rpo2S9rGaEaTKXo=
X-Received: by 2002:a50:c44d:: with SMTP id w13mr25701070edf.50.1555479163323;
        Tue, 16 Apr 2019 22:32:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHjs7/Zoo8NiOu9FhNS2OJVaUQSjg6RW+5oq9zeY2IEwu6KiInKs5TGYndUesL8as/tn69
X-Received: by 2002:a50:c44d:: with SMTP id w13mr25701007edf.50.1555479162318;
        Tue, 16 Apr 2019 22:32:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555479162; cv=none;
        d=google.com; s=arc-20160816;
        b=L2/vFXMum486HcFfBADhIboNcmGL5gxoibZ/HE15s4mLIysFfGPTTFmdv14+sz/x9v
         JeeftW5ThfYcRJBz0oDKxFZJhkr+Pp1ut0PxlooS9mIu16iLnrFLilNOpVTHu+r8UNY5
         sW373Y6bf4rcn7mcxbOBfHcTzVaw5rpR4gwqScwf55Q3ymlQZl7chdq4hEZQiyDzbnD5
         NG6aOYE7WE623nr5SCRfjv9QZ5rCCObwf0anuzCs8FDK+fNvxcpfHOn6b/O2Fh8u2Yz8
         vkyxuusB26oOWgS6HCCC4QKTH9TnUY3BWfj0YCCWsSyxmtmbSWd/nzPJKlDRXFFIp3TD
         DK0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6D+bml0GAKMUKHe87npe+2LGj2+9T7+GwcJmjpz0elM=;
        b=gk791zp6J//I2i6vg5GSt2NXn2SAEvqSiIzFM+H0yZkIrekRib6yI+vBOVrE/zPgSZ
         4cj/fCgPlZlHuG/m5iCaWkTk9jbwo5fe23ri6SSdHxYL9iDyagPWFsQiX6aicJtyRaKd
         biIt5T0q32DhYKjN1yH5BABuXeTko/Z7lSaf4jg9Wwfu6xctolAlNCrFVObLEqjNeU5w
         8nKo3nANLi9h5E3OhkWXb9ps2wwQNUqPXNzpOvZMKP2QWVtsRczWVFApMhf+3NIRLSLl
         sJKj073MAymKTOl2MJjh4J+82qn1x4ljlPzzNBQ844e3lKihxeGoBVZG+iCbH/9Ot3AN
         0j0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id d6si5581786edo.288.2019.04.16.22.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:32:42 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id C815DFF80B;
	Wed, 17 Apr 2019 05:32:37 +0000 (UTC)
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
Subject: [PATCH v3 09/11] mips: Use STACK_TOP when computing mmap base address
Date: Wed, 17 Apr 2019 01:22:45 -0400
Message-Id: <20190417052247.17809-10-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417052247.17809-1-alex@ghiti.fr>
References: <20190417052247.17809-1-alex@ghiti.fr>
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
---
 arch/mips/mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index 3ff82c6f7e24..ffbe69f3a7d9 100644
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

