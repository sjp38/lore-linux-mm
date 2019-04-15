Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DA00C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 09:03:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A8A420883
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 09:03:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A8A420883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A62696B0003; Mon, 15 Apr 2019 05:03:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EDEA6B0006; Mon, 15 Apr 2019 05:03:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B3076B0007; Mon, 15 Apr 2019 05:03:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEB26B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 05:03:06 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 7so14173837wmj.9
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 02:03:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=H0Af6KOS5yo3Cqn5M3SwYoAMjmGvFzR0kAx47HyHqlc=;
        b=YXOyeXWljqtd18itGISp1BkZ09ru0YaFK3oOIlRfjhKFd95DwWOt4bIFKA5GhHpq68
         4csDaTaO5ctffJ1au8B0h33zAfNd3lBGzcH1JDVJZWXhSobO+m9SzWZaOkWyY0EkBrmW
         ikxY9SNLsao4sMK7c2YIiqXSkGk/0D53JrwNuZ/goLPleqecq7l+tBHpffuIjWyGBFXr
         +to4pWqGrVTjh3+7gGiZNhrgfIqO71W+CzLLYja1LsXx55ZPVP+qiyyPoGiQdP3b2qDR
         J0HwYl/6erCH8eYsXVfGfL+Zca4+SmlFflZXc9wh/qmIVLwnGz2Vx77Z8CA5M+6lef57
         A9Ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVrwjsm6y7OraaGTZslx0ToO2hNcjsJkSN3N+SPytQ+m4g1nEkJ
	N304VNuqalNijEn40nsthApmcwJO0ctSrK2+v9uTcxtwoRjH3MgGYeHaLKvfgWxze4gsDrKtGuW
	yghSBpx6epT88Zl1R0GZ8sUQli5uBpreadfXS2YDDNgBo/CJRkNV4fLEjykvuHu1AHA==
X-Received: by 2002:a5d:6a0b:: with SMTP id m11mr45048356wru.290.1555318985627;
        Mon, 15 Apr 2019 02:03:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlSWTmU1+Iz4EG27nXL4Ss5H7f5g8rnEwqjoDKbqyt9zKogG87AVqjqMuwnvFshj0KHuqr
X-Received: by 2002:a5d:6a0b:: with SMTP id m11mr45048275wru.290.1555318984638;
        Mon, 15 Apr 2019 02:03:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555318984; cv=none;
        d=google.com; s=arc-20160816;
        b=sMslJxMY3jf5uJqvy15BESO57xHW50gDHgGhHxrSkvt/ZE6rvFUrhSU8n9cqv9zUB8
         2vQ1WP1zpaAxNnu8u8J8qU0JYFXAj2J5GOeh2pZoCgCAQrg4BFYuom5BQpAVa3xGLy4J
         B6GmqRzLmHrRuPt6917SqzcQ/lvXIuoSQrz0v6PQmX1CWp+34y1cM1TDUV/cEDuOV2RF
         UVCm+l5YYuNctuoHgIY1nqH0PGq9rHK0eMQnZNUtysquY0D2poFc1s9PAFVaR8VNh5CL
         bWgrA7RtdPXyfyinj1+rM9svVoa/FamRmeoobUIeUHiA36BGRq21mT47SsljymvNtTTp
         wIUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=H0Af6KOS5yo3Cqn5M3SwYoAMjmGvFzR0kAx47HyHqlc=;
        b=KvEdURl/vGQ86WhMch4P60GJQX4AjFXAO3g8+iLmG2tVNsXNCm1+hOFPPz6QcYG78o
         kysK700z4uE4z9rYHbs4W7C/l+hVC/QwqBtcmsabevHpB4H+0cJy1lkuNzzowVMICcgU
         wmQOVlKE02igCgeaBzGiSEZiJunFxKragzoPjzBlBCRYJt6qGzUtBoL2PD/Ryid/SZ2s
         UGd8NVqyEsSXmm9rCsUEJtXoFGQILLTp3TATBMBSFQN/RwmpWhbjLFikEmL8EVBEVz8b
         KzK79BfDe0Hg7NHMY6sRorh2LZ8tS2u475OQdYBBo7hk09wso7OJXG0lYdBP2znxkKJ9
         r0kA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a7si27174960wrv.49.2019.04.15.02.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Apr 2019 02:03:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hFxVy-0002zp-IB; Mon, 15 Apr 2019 11:02:58 +0200
Date: Mon, 15 Apr 2019 11:02:58 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Andy Lutomirski <luto@kernel.org>
cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
    Josh Poimboeuf <jpoimboe@redhat.com>, 
    Sean Christopherson <sean.j.christopherson@intel.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: [patch V4 01/32] mm/slab: Fix broken stack trace storage
In-Reply-To: <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
Message-ID: <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
References: <20190414155936.679808307@linutronix.de> <20190414160143.591255977@linutronix.de> <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com> <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kstack_end() is broken on interrupt stacks as they are not guaranteed to be
sized THREAD_SIZE and THREAD_SIZE aligned.

Use the stack tracer instead. Remove the pointless pointer increment at the
end of the function while at it.

Fixes: 98eb235b7feb ("[PATCH] page unmapping debug") - History tree
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org
---
V4: Made the code simpler to understand (Andy) and make it actually compile
---
 mm/slab.c |   30 ++++++++++++++----------------
 1 file changed, 14 insertions(+), 16 deletions(-)

--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1470,33 +1470,31 @@ static bool is_debug_pagealloc_cache(str
 static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
 			    unsigned long caller)
 {
-	int size = cachep->object_size;
+	int size = cachep->object_size / sizeof(unsigned long);
 
 	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
 
-	if (size < 5 * sizeof(unsigned long))
+	if (size < 5)
 		return;
 
 	*addr++ = 0x12345678;
 	*addr++ = caller;
 	*addr++ = smp_processor_id();
-	size -= 3 * sizeof(unsigned long);
+	size -= 3;
+#ifdef CONFIG_STACKTRACE
 	{
-		unsigned long *sptr = &caller;
-		unsigned long svalue;
-
-		while (!kstack_end(sptr)) {
-			svalue = *sptr++;
-			if (kernel_text_address(svalue)) {
-				*addr++ = svalue;
-				size -= sizeof(unsigned long);
-				if (size <= sizeof(unsigned long))
-					break;
-			}
-		}
+		struct stack_trace trace = {
+			/* Leave one for the end marker below */
+			.max_entries	= size - 1,
+			.entries	= addr,
+			.skip		= 3,
+		};
 
+		save_stack_trace(&trace);
+		addr += trace.nr_entries;
 	}
-	*addr++ = 0x87654321;
+#endif
+	*addr = 0x87654321;
 }
 
 static void slab_kernel_map(struct kmem_cache *cachep, void *objp,

