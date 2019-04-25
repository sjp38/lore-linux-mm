Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A46CC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C896F218B0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C896F218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 395896B000D; Thu, 25 Apr 2019 05:59:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B0316B0266; Thu, 25 Apr 2019 05:59:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F047C6B000E; Thu, 25 Apr 2019 05:59:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4C76B000C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:18 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id j22so3963035wre.12
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=alIh8rahgpiXntod9mcGH1EU5xt1zZgE1HpQXO2eGOc=;
        b=sa2za0KH8KjcLdHVS1hox6vyRvc/JEeftO/iGqfeKFQedtuRgyEdTsENNiCMX5YGXB
         t0F4sy0Lk09ka7j3ovlsvHpLdN7How5DZRnBDSjoyUY5fF2ulU+EhYr5gAd/tziGD96r
         FyOemkYrZHrfsAY6YALuy+OKtWqylO3UEYIE3jJSMCHXcOYRXmzn+oQceoSO1MraKXTO
         YNE0gKM6oQgL7n14h2+k8HlU8hCzswI+cB3A6QrGlMeQCWBivzgBQyg5hrRxU7iVz5mU
         4/vhKsBLSJ/tillDTMdtumThslCjvQC9nQ9ySecLPDYPGr/Zm1hJLQmUlDH1kD8zbRm+
         dMRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWI6n1oOrEswMYAkZFGLf3GFufD+DmwmT++FJjxha/vYwKMatsN
	i3W0J2Ic/zbh300EOVKgZEw1LQGBToqxxd7F0IUyn2u8LLxjQQKvhCzUG5yDivFyz3DdfmqtGsJ
	iHWm8fZLYn6BdbyeAGXNVoP+tEWwgH/nPd5QB5FMgqfHaLTqpzrAebmE7eWpKYTV+KA==
X-Received: by 2002:adf:d850:: with SMTP id k16mr18787096wrl.35.1556186358013;
        Thu, 25 Apr 2019 02:59:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/NMhbS3tp2m1BXiOzL+RUPNvOkTCWFD2A2bXvi3bIvddn5CDnj2w+vhqqvS1RaYs1gl9l
X-Received: by 2002:adf:d850:: with SMTP id k16mr18786991wrl.35.1556186356117;
        Thu, 25 Apr 2019 02:59:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186356; cv=none;
        d=google.com; s=arc-20160816;
        b=V9NPt6jm0gbsPIx+2F8P5TRljYPZHFmM7/3IJoySaX3+b+OPmZtg60anP0mx6nKiFR
         EZM30d37+6ThU0CNqZN2Py+7DcFkwdHQWSjmMEB/ZoQSNeCRHHdjhFH2Ls2LDxoLYRvd
         IEerrHKgOcmKtnqbyCaLI+EQMqrfzfKJg+fpEzwpMS3D+daIXP2NFOe6EkotrPvqEuP4
         GXXCFB08uuJdUlFfA+B4Lb5ttpLgzhnDnR0lECDHN1EQHxHnxhzslJZ2IcCXWACGf+Nm
         7CjVo8QqPZWS3STxCpfEhKWPGl8xM2zqgPzvR7xSa8xr2u99pKCiLj4YBp6TjgJYIBBf
         zr9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=alIh8rahgpiXntod9mcGH1EU5xt1zZgE1HpQXO2eGOc=;
        b=HUhp5mW07PWVEhebZL8qvEtZNlzWc0xIpkjxzYDdFgMx373RHKUSmyiejERpgQ6s1k
         7d03La8OVdCHRlIrFslni2YMXmtuH68+mHWChoiWCG+4EgPbQvSbaQ52zrGXHTLUP/5S
         zjp9K4UfLTUwjz9RsNQTRahkXj/qJ3ft43P2bKZjgbxW6r9HmWcdNZWLhnOj/HoG7Wd+
         iblUNA0NuncCNRT1jonzJBrJfqIsY1BkhVEhGv6zH4+ha4/yGIRFHICmfJJAbP0jVszo
         NjWZbvIfjwwqNyZVCvmcAcdngrrVde7a4HSu95dru32T/m+XJAbgq8xifXxjU1XyMlXz
         O0qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g18si339838wrx.87.2019.04.25.02.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9v-0001rW-1P; Thu, 25 Apr 2019 11:59:15 +0200
Message-Id: <20190425094801.963261479@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:02 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, Christoph Hellwig <hch@lst.de>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 Daniel Vetter <daniel@ffwll.ch>, intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>,
 Tom Zanussi <tom.zanussi@linux.intel.com>, Miroslav Benes <mbenes@suse.cz>,
 linux-arch@vger.kernel.org
Subject: [patch V3 09/29] mm/kasan: Simplify stacktrace handling
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the indirection through struct stack_trace by using the storage
array based interfaces.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Dmitry Vyukov <dvyukov@google.com>
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
---
 mm/kasan/common.c |   30 ++++++++++++------------------
 mm/kasan/report.c |    7 ++++---
 2 files changed, 16 insertions(+), 21 deletions(-)

--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -48,34 +48,28 @@ static inline int in_irqentry_text(unsig
 		 ptr < (unsigned long)&__softirqentry_text_end);
 }
 
-static inline void filter_irq_stacks(struct stack_trace *trace)
+static inline unsigned int filter_irq_stacks(unsigned long *entries,
+					     unsigned int nr_entries)
 {
-	int i;
+	unsigned int i;
 
-	if (!trace->nr_entries)
-		return;
-	for (i = 0; i < trace->nr_entries; i++)
-		if (in_irqentry_text(trace->entries[i])) {
+	for (i = 0; i < nr_entries; i++) {
+		if (in_irqentry_text(entries[i])) {
 			/* Include the irqentry function into the stack. */
-			trace->nr_entries = i + 1;
-			break;
+			return i + 1;
 		}
+	}
+	return nr_entries;
 }
 
 static inline depot_stack_handle_t save_stack(gfp_t flags)
 {
 	unsigned long entries[KASAN_STACK_DEPTH];
-	struct stack_trace trace = {
-		.nr_entries = 0,
-		.entries = entries,
-		.max_entries = KASAN_STACK_DEPTH,
-		.skip = 0
-	};
+	unsigned int nr_entries;
 
-	save_stack_trace(&trace);
-	filter_irq_stacks(&trace);
-
-	return depot_save_stack(&trace, flags);
+	nr_entries = stack_trace_save(entries, ARRAY_SIZE(entries), 0);
+	nr_entries = filter_irq_stacks(entries, nr_entries);
+	return stack_depot_save(entries, nr_entries, flags);
 }
 
 static inline void set_track(struct kasan_track *track, gfp_t flags)
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -100,10 +100,11 @@ static void print_track(struct kasan_tra
 {
 	pr_err("%s by task %u:\n", prefix, track->pid);
 	if (track->stack) {
-		struct stack_trace trace;
+		unsigned long *entries;
+		unsigned int nr_entries;
 
-		depot_fetch_stack(track->stack, &trace);
-		print_stack_trace(&trace, 0);
+		nr_entries = stack_depot_fetch(track->stack, &entries);
+		stack_trace_print(entries, nr_entries, 0);
 	} else {
 		pr_err("(stack is not available)\n");
 	}


