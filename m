Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A489CC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 517832087F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="e90YIYJE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 517832087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E747D6B000E; Mon,  6 May 2019 12:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4DBB6B0010; Mon,  6 May 2019 12:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC7306B0266; Mon,  6 May 2019 12:31:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA3EF6B000E
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:17 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id e5so26243704ywc.8
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=x8HMVSO2lCP9thpVq0jteC8wa+ruR/qG5sfvMEzcSf4=;
        b=U5q0N845fftM/6PnwB5mEvG0ZVZeKSBxroi14l31su0uAyxyU/gsO2h4hstLnQ87MS
         /9zsgv5kwpOsZDbuvJxdDYsixcYz/JFCFP19HIN2Qs99gf2RsWBCbb0N8Q5lHD38wkLT
         hRnNzsgB+14oHgrPfY0prYTh4hzX5Ti5y7LO0TUcwpC1z+n+fVafXhYxZyicFuerhjP+
         NyzkFV1jH0GV3JLE2FUmYrhPFxX/YEAzICr1I6Vtg9xHxotLhfwfeeKtZrkBnC+Syhx3
         qqaaPWXG/rzaOCXtOO1GFFpcQEp4zt3yutOKkl8q8XcpKo/l4JBSXbViOznBamFOLCgj
         dmYA==
X-Gm-Message-State: APjAAAXkt6ku3p9r77Tw9uEpnJ/t5EsY2dyLOs+qtBla7KdxpkxumYQN
	kHZ5N/fq5bocumtPThKPGt/nW9s/JgRhzuu6aMyFwwnqakt3qg/cyc6QEi/VWvTll7OdWOc2z0j
	LrmohFgk4qnu5f8EdEIaTcweshK/034W4ROI+hXiyV9mL0PDePLQxJ6ud7JASHn8HIA==
X-Received: by 2002:a25:6882:: with SMTP id d124mr18484022ybc.285.1557160277458;
        Mon, 06 May 2019 09:31:17 -0700 (PDT)
X-Received: by 2002:a25:6882:: with SMTP id d124mr18483976ybc.285.1557160276813;
        Mon, 06 May 2019 09:31:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160276; cv=none;
        d=google.com; s=arc-20160816;
        b=wtRwnsenW8ZnT9pHdlA9JBMjOfJ0zJpDEY3KE9m05XaaZwtGfqkKbeTImBSBmuwPJL
         zn/vnXMkTE32+V0S3APOo43zJNDVyjVDKydm8fm/H4doiEx7J9Z8u4PvgfEAnWupv9z6
         Ps4oUyBaXkbsckfkWv3aBC61AbDVS6zxtCsADy8szGqWyHMfKmVg170GDqf5luCgO3DS
         hlTwXXo2oD1lJTFs0Mdsgfig95yZmabn5mEJ6tJtBqGRWmVmKVNgQHH7573ui/5bTDzH
         4Wb7DeAYjcn+y7Ub34ebgSdxl+aaRk/BJvK4E3ZkDd3m7QM60HGycjVRx64wcHcKaEkr
         /Tcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=x8HMVSO2lCP9thpVq0jteC8wa+ruR/qG5sfvMEzcSf4=;
        b=HhcSkEmlDz4L7cFlaLcE3nTqJDJ+2t+2+gBiFTpqa2oCMCo3OAafOfkzY7UCqQrdCG
         Z1SbjRJ1Onl8X2v9OwwYs6ujkoVbK/ea2FGGVfSjtHCegveTL4h6y6ZcVODLyc5Id402
         QYg1JNyCZIRkM1xdTRAFPqSJ2ksLQeagdz93KH6ou/Vq3IMZJT8ihJafL8v9WzT2Q/it
         Z34PSbrozYBeqiUSXJIMvOUdi6SL/9WXFUamSbaqZ6OmHH5F4Kta107rJ/lVbh7FSheW
         hf0jRau7IMMS5n71ZoqovPlhRX8SB8zKFwopVD9QS0f0viYweXfh5pGk7pzRHnkwsfMU
         IitQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=e90YIYJE;
       spf=pass (google.com: domain of 3vghqxaokceuhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3VGHQXAoKCEUhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d6sor5366232ybs.103.2019.05.06.09.31.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3vghqxaokceuhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=e90YIYJE;
       spf=pass (google.com: domain of 3vghqxaokceuhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3VGHQXAoKCEUhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=x8HMVSO2lCP9thpVq0jteC8wa+ruR/qG5sfvMEzcSf4=;
        b=e90YIYJEqCjuv0dQNXe7JfByZ3LYw/uoix1gLG6qHxakrZEGoit4yh6fTDsfYia+jH
         wb7igUzrFQvpjJl955zqS3eb64AMNM806CURkcixGS6z1rzCJzMGBiAz82rRhlhjgKjR
         9cdDyeo/3JMugM0eGAxc56H2X/rF/Gu5NZJ6OlTvycYfBxRjWeovYDz5GGyc2/popU6X
         Q4rJTvbhNlqr5zqGtmKCjWUttV6dsKWcbk2qBw0aV1In8VLH8mRF5MiPk8iCO4KWMnPF
         BSI3N1BBXtSHWlnz3+Iji+1TK5JldUspg0pnnlvUCK4PaDa6c2GsK9cElOVCY5yx3kNx
         bcTw==
X-Google-Smtp-Source: APXvYqyZq8rlWFW4uBLN8C8I3oEaQAU5CNW3HReq+6c5opQ9wp/VGDDqgMMeEo6tOAWNlA3+Gfl3rFVlDcMv6bDq
X-Received: by 2002:a5b:8c2:: with SMTP id w2mr16278460ybq.201.1557160276487;
 Mon, 06 May 2019 09:31:16 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:49 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <861418ff7ed7253356cb8267de5ee2d4bd84196d.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 03/17] lib, arm64: untag user pointers in strn*_user
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
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

strncpy_from_user and strnlen_user accept user addresses as arguments, and
do not go through the same path as copy_from_user and others, so here we
need to handle the case of tagged user addresses separately.

Untag user pointers passed to these functions.

Note, that this patch only temporarily untags the pointers to perform
validity checks, but then uses them as is to perform user memory accesses.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 lib/strncpy_from_user.c | 3 ++-
 lib/strnlen_user.c      | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index 58eacd41526c..6209bb9507c7 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -6,6 +6,7 @@
 #include <linux/uaccess.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
+#include <linux/mm.h>
 
 #include <asm/byteorder.h>
 #include <asm/word-at-a-time.h>
@@ -107,7 +108,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
 		return 0;
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)src;
+	src_addr = (unsigned long)untagged_addr(src);
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
index 1c1a1b0e38a5..8ca3d2ac32ec 100644
--- a/lib/strnlen_user.c
+++ b/lib/strnlen_user.c
@@ -2,6 +2,7 @@
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <linux/uaccess.h>
+#include <linux/mm.h>
 
 #include <asm/word-at-a-time.h>
 
@@ -109,7 +110,7 @@ long strnlen_user(const char __user *str, long count)
 		return 0;
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)str;
+	src_addr = (unsigned long)untagged_addr(str);
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
-- 
2.21.0.1020.gf2820cf01a-goog

