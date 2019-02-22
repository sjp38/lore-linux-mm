Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14EF2C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB3F42070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IZO5qs1i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB3F42070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2C058E00F9; Fri, 22 Feb 2019 07:53:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED8C08E00D4; Fri, 22 Feb 2019 07:53:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D54D78E00F9; Fri, 22 Feb 2019 07:53:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CFA78E00D4
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:35 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id y1so951741wrh.21
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LYedl6oW+X0hODfB6yBlRZE+wsBGKemR/gV1w08gXes=;
        b=s9qax6D7f62vqv7wB6XORI0WyWlv/ZBJKDbSwm90IH4zEMmRa5ZDl3Cyj/Sy6vWEC6
         MdpRapBfmzqheF3jKA0slqrubpWs+cU2d2BcYN6ELikL7kXICbcbPubLDnau7ob5DjaR
         54gf0Gr3lVsBNbihDYHvnF8N6wZW8Zqv70GAqcdjucFBgm2/kf6A4//EWaTdc6shR38A
         JV/THrTKE3+I2ISt5IHAwq6vBaawZq0u13JgSYhrEkkdgNCvTs//r/x1ptklUo1SYkbr
         PaGjAmhvzMvHj2inBl4HxzqqItDFZCe5fN44MG06WuLc+wFEohHo38x6Gp2P0N+UFoGo
         0QCw==
X-Gm-Message-State: AHQUAuauD3E8eBk+lzjahJB31X7q8ReCRkvrTMnTq0CxkkG5BXm0aRw2
	CScUL0y5X5n0/gD2Op+S8W0KEBqbmI3KHHzIr5XOjQc1QQMvRX5V1t7rduC/ptwHpPUuhKMWATS
	owZ7mswzreqhm3BxqkPuSyc1BaYISudmvxNtJqc23IZJx92au+wrjz8QMQWiFHVOmIRqta2MuiW
	new3ZmZl/Zx4IOTpR/gGN17uYWMDMOySteUzDd37c28tFkwq1jqdsbS/VEQ/AkbeoOvq/gishRt
	O2PM9pcGsauumpuen9kHPctBuDQhTBzGE7oigcW0bosXFkKvLyqitLBYPC0ZRKz39565gpfm4N7
	JS+sjAiwUR2w3qd1FAUGFdncie94YI5eXiAaXSumNvzZHhJYP2N/VZQBhtXUDxEekjkCkON1haM
	Z
X-Received: by 2002:a1c:dc0a:: with SMTP id t10mr2442511wmg.101.1550840015026;
        Fri, 22 Feb 2019 04:53:35 -0800 (PST)
X-Received: by 2002:a1c:dc0a:: with SMTP id t10mr2442473wmg.101.1550840014233;
        Fri, 22 Feb 2019 04:53:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840014; cv=none;
        d=google.com; s=arc-20160816;
        b=a1g3Zj/rjo2aVEVf36evF8p7QxRqesOQvYe/+5xDf1SSy7fofax/hoxkrijJZqHULP
         RV5xJ3LRYn/sgRsRV+3bhx35eUmxFZrmhqc7Q5/28QLbuy1CL9ACzK16L5R6k3CKS0W7
         jkPM+XGxQNSDfDlM9C0bqArt1NJRgbNGIpaL2+VHfg3m19VB63v9bPmZmYh8u7cCJu65
         n6wrxR+9HCYnmOSBuZNzDe3IAhlHfjKyBcTWJkuvNn3BTReYpsGN1fEr9KB03hldRfLg
         x/vw+pU2ysI0b17yEJvrmRGfM/8605wWGHqTlX6F3rxny6HGKfH2pVHGxhj+uxt3Juve
         FV6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=LYedl6oW+X0hODfB6yBlRZE+wsBGKemR/gV1w08gXes=;
        b=WQNvRVsacEq5zwTn4pJHq5IdJpMWVgAMBF+UUV14HG2bqR2GNFTyg+MrBj+AXDDhAB
         DFcCN7QteDxnkjUmEHxE3q3h/kstmNW8VEj6JyNHChbnDR5CY9y+IcGTIJpLwrYaCVu6
         kdjPsPWOFgY9Qb5uZC8ZrePOoDfjec9amfBtzYSbTANxVMuNIcrE78HQjVBYs2RmvDm0
         9KaGgUhEg8R0tf9+3d+FtTAuDWcI8A44UPwvEXI1JX59BRAMjfQok/QDsEkq5SZ6oM+5
         bhILzSIUldD1SZWcGYAbRlBUOvmMOkHbb0OMT+acJGpbaXfgIlbJhC+xhwNB1Mb/Jfs2
         55bA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IZO5qs1i;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7sor1108276wrv.24.2019.02.22.04.53.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:34 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IZO5qs1i;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=LYedl6oW+X0hODfB6yBlRZE+wsBGKemR/gV1w08gXes=;
        b=IZO5qs1iTdFS0J8b6mUPkT96MHj4TvOOl4p+NkYj+K5QoPzgtV+ykf7Zu+OkLcqN2H
         XG3Gh3bG0jBem6M7NTIzz/wK5zl+vCUUNfkfJALSmU8Wj9A1u4sBy3ay4BW4/EmB0HRO
         rjkA4MwD6TdBTXlf++HuBJnMCfJk5iZzI3+4sXCvRuZvNLxSnSX00w7f+r2eMb9tbUeZ
         wKQkxlkxUte2ekBF+Cqk930FiD2BqGhYurasbJZ5Cy6szPm8dYUDDnFl+i7USfSEW4tE
         b+242VIYnFJCUhKNVLIKvM7y8Jwt7Fku92E8DCxmA2ENAr03DmnPf5Nks+jfBd0lKf0N
         y0ng==
X-Google-Smtp-Source: AHgI3Ibs8M2cAwjQZj6orbXxkxYi8LGidQwEOKdpOteZ9oefSzL6DNYvYhuV2aOjewxHuzIPLDjC/Q==
X-Received: by 2002:adf:e90b:: with SMTP id f11mr2972186wrm.36.1550840013762;
        Fri, 22 Feb 2019 04:53:33 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:32 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v10 02/12] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
Date: Fri, 22 Feb 2019 13:53:14 +0100
Message-Id: <e069abcfd4d2289a32f0a1e5b13701b99c42f82e.1550839937.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <cover.1550839937.git.andreyknvl@google.com>
References: <cover.1550839937.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

copy_from_user (and a few other similar functions) are used to copy data
from user memory into the kernel memory or vice versa. Since a user can
provided a tagged pointer to one of the syscalls that use copy_from_user,
we need to correctly handle such pointers.

Do this by untagging user pointers in access_ok and in __uaccess_mask_ptr,
before performing access validity checks.

Note, that this patch only temporarily untags the pointers to perform the
checks, but then passes them as is into the kernel internals.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/uaccess.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index 547d7a0c9d05..9b9291abda88 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -95,7 +95,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
 	return ret;
 }
 
-#define access_ok(addr, size)	__range_ok(addr, size)
+#define access_ok(addr, size)	__range_ok(untagged_addr(addr), size)
 #define user_addr_max			get_fs
 
 #define _ASM_EXTABLE(from, to)						\
@@ -227,7 +227,8 @@ static inline void uaccess_enable_not_uao(void)
 
 /*
  * Sanitise a uaccess pointer such that it becomes NULL if above the
- * current addr_limit.
+ * current addr_limit. In case the pointer is tagged (has the top byte set),
+ * untag the pointer before checking.
  */
 #define uaccess_mask_ptr(ptr) (__typeof__(ptr))__uaccess_mask_ptr(ptr)
 static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
@@ -235,10 +236,11 @@ static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
 	void __user *safe_ptr;
 
 	asm volatile(
-	"	bics	xzr, %1, %2\n"
+	"	bics	xzr, %3, %2\n"
 	"	csel	%0, %1, xzr, eq\n"
 	: "=&r" (safe_ptr)
-	: "r" (ptr), "r" (current_thread_info()->addr_limit)
+	: "r" (ptr), "r" (current_thread_info()->addr_limit),
+	  "r" (untagged_addr(ptr))
 	: "cc");
 
 	csdb();
-- 
2.21.0.rc0.258.g878e2cd30e-goog

