Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA937C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6AFC2133F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="daRRCGEX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6AFC2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44E568E0008; Mon, 24 Jun 2019 10:33:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FFD18E0002; Mon, 24 Jun 2019 10:33:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2797D8E0008; Mon, 24 Jun 2019 10:33:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 018748E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:09 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id o202so6445721vko.16
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=OFC24w2VYFjptSxPqCpbBEqhaUlc2rZ4vtg/DxWHKUY=;
        b=QNP+ooVESB3M4LCDHf/Pc6bxeHbrTr+isa3inTtbXJPepuH8yvVDGKK8BaXW+u1aiQ
         CSjEvCqjT5gzHTCZFWjG7utFW2VQe0u4vlyi6BIG3TUH8QHlJZ1FOe2pfBno0MnCghkD
         Qw9Siem6xruMUU/DyD4yZgegcQ1YxfDnm5xuaxeyiT+fW+Hyh1rJI2cE93vvt94CFu1j
         odUjzZE5rUvIUN5AxnIw2Qpgp9o18HvvnVUcwAWXvHWTn7BGGgOXWv2lGu86OQZp5t81
         xs8pU3ff5XvFX2cWQRR4UHVkd1Q50eCxZ0gAoC7bx8gzN8n+oBNrZjl08AnkeAL5NuPC
         WYIw==
X-Gm-Message-State: APjAAAVJYe4feEKCzwoxC88zLMvf0LyDMGhi7ajtD1ZSP0dxKlcPLiFk
	kjbMymtdRvD25s8QjDSk70iH4HIvCSqvLjpTGL7Jn7DKKQckO7dRpo5Y4r8dGt24NFj0/ZbxF9t
	V/PfuMO03PJ9T9s7YoJ4R0fC2NtLVuVDPTXZN+O26txjioFYNYeVy4xFpbgdXUWyj/A==
X-Received: by 2002:a05:6102:114:: with SMTP id z20mr17405341vsq.187.1561386788619;
        Mon, 24 Jun 2019 07:33:08 -0700 (PDT)
X-Received: by 2002:a05:6102:114:: with SMTP id z20mr17405313vsq.187.1561386787920;
        Mon, 24 Jun 2019 07:33:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386787; cv=none;
        d=google.com; s=arc-20160816;
        b=ZjRGlW2V9k/4k7s5t+iME7aw6woBML2FMjPtkfom1DExPZbdz4bJw+Q1Xqn38kjzQN
         5nzMYusutDZxyRgQvGeOLE1NiOtzD7cb+6zmApr81jFda/Ie1pmWOJf6EWtFm3AZ8Lf1
         PGCsQ+4Sv1P6RFFS2bEwHbiGFGWMwtE+gWYP2aU9FUWlDW2Rg061ylraJi9n0AjXLH/i
         L7bUSY9lBUovs8ZgwpEQWmXdYR3Vu4d/kEMlHtaeUfwbN2ix1fIgELpDlACSNWU8AaMp
         Y/5l1g7dgGOl8WMtcdKO/R/cVCNwyXB5iL0FtRaX/N0ZABmzpsn2AEr7E9wpAAuM75a/
         8AWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=OFC24w2VYFjptSxPqCpbBEqhaUlc2rZ4vtg/DxWHKUY=;
        b=axk5PWbop/UI2bGra02D7DvsbJMJ90GLjfn/q9cIq/i60Dq5pEmcS3+6/B3Tri+q9m
         9+deCbsOoSRiQ99A2U7OzPRqV2xvaSpfzE4NgFyiHIBe/zALkDPRUJajjTK85RY7+6fQ
         FJKP3uXbZsyR0B/RglQKcBDbSVlZBmi0JoHm7/wSwsF4q4lfDDjsqFPI4S4Q4oOdtkvs
         RT3nqC/a9LeO8SVBOBNw91RMhAYpMhz0trrgfkDBCvcj8nj0hYrd5o9pUtihutW1XKdB
         McwVyLMXuRQE//LMpYFn+SWkQkupIIzbmGUyXhMhG8pNYXsghszqpOB4k3ZgS6egGuxK
         uZdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=daRRCGEX;
       spf=pass (google.com: domain of 3i98qxqokcbqu7xbyi47f508805y.w86527eh-664fuw4.8b0@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3I98QXQoKCBQu7xByI47F508805y.w86527EH-664Fuw4.8B0@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f16sor5687550vsl.71.2019.06.24.07.33.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3i98qxqokcbqu7xbyi47f508805y.w86527eh-664fuw4.8b0@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=daRRCGEX;
       spf=pass (google.com: domain of 3i98qxqokcbqu7xbyi47f508805y.w86527eh-664fuw4.8b0@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3I98QXQoKCBQu7xByI47F508805y.w86527EH-664Fuw4.8B0@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=OFC24w2VYFjptSxPqCpbBEqhaUlc2rZ4vtg/DxWHKUY=;
        b=daRRCGEXfLHGLUQo//HRDLfqaBO4lfL42FrfPGRnRKOhn1XL6qGzvLE8amzWfXer5a
         WhALrZBTuSnnuN10/CaZpZqQ5oMU4MQefeNJm/AP0b4uEXgK32RunU93durvNp8XKKHL
         uQfK0a3nA5oC/DUYeVxUqLVQFd9uJpb2OtV7FV9mAWqDzJacQiBSNlyVGMSQHbzkOff3
         MC+xIW6PfIq1tVQloxoUTZ3GncOdewoLB+fLV/jb+kaJgM+7s5iRXhY273LkR2goOH7a
         Ap1pVnJAk4onxG8CZjucr85/ku+lb+LecGyuZhueMHSpk8X8CCgAIxuGrhQgzxcP8FnL
         C2Sw==
X-Google-Smtp-Source: APXvYqztHTWRHYOC83H4IfNbENBsJMJpCmuVpe91PkFE56CWhu5KbIzw0hmUvviWu8/4yX8wEpc7iI+Lm7IC+LHT
X-Received: by 2002:a67:6e44:: with SMTP id j65mr66559877vsc.132.1561386787480;
 Mon, 24 Jun 2019 07:33:07 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:46 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <98cbd89549395d372a4a20ab2ac536bf19d37e52.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 01/15] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

copy_from_user (and a few other similar functions) are used to copy data
from user memory into the kernel memory or vice versa. Since a user can
provided a tagged pointer to one of the syscalls that use copy_from_user,
we need to correctly handle such pointers.

Do this by untagging user pointers in access_ok and in __uaccess_mask_ptr,
before performing access validity checks.

Note, that this patch only temporarily untags the pointers to perform the
checks, but then passes them as is into the kernel internals.

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/uaccess.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index 5a1c32260c1f..a138e3b4f717 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -62,6 +62,8 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
 {
 	unsigned long ret, limit = current_thread_info()->addr_limit;
 
+	addr = untagged_addr(addr);
+
 	__chk_user_ptr(addr);
 	asm volatile(
 	// A + B <= C + 1 for all A,B,C, in four easy steps:
@@ -215,7 +217,8 @@ static inline void uaccess_enable_not_uao(void)
 
 /*
  * Sanitise a uaccess pointer such that it becomes NULL if above the
- * current addr_limit.
+ * current addr_limit. In case the pointer is tagged (has the top byte set),
+ * untag the pointer before checking.
  */
 #define uaccess_mask_ptr(ptr) (__typeof__(ptr))__uaccess_mask_ptr(ptr)
 static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
@@ -223,10 +226,11 @@ static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
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
2.22.0.410.gd8fdbe21b5-goog

