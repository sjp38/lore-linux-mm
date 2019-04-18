Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72577C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DD1D2183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DD1D2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 495566B026A; Thu, 18 Apr 2019 05:06:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41DCB6B026B; Thu, 18 Apr 2019 05:06:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C0316B026C; Thu, 18 Apr 2019 05:06:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id B565D6B026A
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:17 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id i184so1519269wmi.9
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=vE/h4iTaYWv2pX1V6FXNHaP6c7n1dI5SFaeY9qpaUbU=;
        b=s0GTE7OJD1KYSLdZOQCVulaTWf6+9tQLGHZjagIqiQyWHV8LEx2a32g88vRU8HZorP
         GyNqVtMhgNFxncK8YeQVaohgvymvVcQBV+RmLoqK1hOq9w7dENVfoSS32qapFlb3orEe
         +0gQKxP1oMde7HnSfVeIGdC/3KhzPrqyPlWtvd2zL4zuE/kbqdVwZLeWQXlrBmuYFzb4
         9gzK518jV8BJXrfxw2NOya7Cuy9gHArikOpP6SXKJQNo0SaWwgqZCyeV64xAvTy0tbK5
         4bSxWwsy0G8uFgqnxLLvcl9gkmpOzeOM7QKZ5CNFeyskMCbZ1eRha9nUIaxoL2nPA7mq
         zDCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUCaXNPvszblYnnyspFPDDoGfD3f/3RiSuTHgWij2Zb1Rei1j6B
	Yp9pPZL1HUwTac/8qUYjI0YOTklehWW95vxtLr2ki6Op8mm4UeVP8DQUOLvUL4mQjSIQrjqz5bY
	hla1ym3EVQLoyCRgfIgsNblB0vZxOPqI43IG3uPTvNEOuik28b9LYplH0sm4X/NLR2g==
X-Received: by 2002:a5d:4a8d:: with SMTP id o13mr47878306wrq.209.1555578377275;
        Thu, 18 Apr 2019 02:06:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz262Qh0LNuAQSJZPguwLT1QLX0B8TWwuB9CcF4GVzJy51k6fAvkUJaOutlyidEIKmbsEka
X-Received: by 2002:a5d:4a8d:: with SMTP id o13mr47878226wrq.209.1555578376120;
        Thu, 18 Apr 2019 02:06:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578376; cv=none;
        d=google.com; s=arc-20160816;
        b=ggTJfWyZ8g620EzzVc96108Ya5Ne6fYTWZ9X1HIrQpKc/z89ngM8C/3HQCQ+xTDa4l
         6pJfX7l7hrCbyxhmDnh59P3fBZoUhZIFcjCOVGJHfBhdBMy9pqrd9ip9NmAZvagjEccC
         +Rd9dDyC1TsSBR/npitDbxGqlvffisJJ/e44jOTK2YW757ZgWQZKPoUGUNAQ+Na7TdrN
         oe5/2yPRzsXzZhuLlpzag4FB61kCAK8Gr/U8ITkPbu5/NVuZyc0beNozaXFhaVmVJ9Aj
         u//XKBFs8FPpcZoffCLT7PPvCFOTEX28XdDgokEPXMYxjPCJKd+NYKRotu5h2IxVDz8C
         eznQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=vE/h4iTaYWv2pX1V6FXNHaP6c7n1dI5SFaeY9qpaUbU=;
        b=yy2JiYC1f5mV/vpd8wg9j77bKGnFeNmUptHTtRB43syvbf5qdK9gMJ49Xb51QF8ajD
         vQrxIcJeWx11aUfmg1J3Eld0fKdqbRxH/BjF2p8BQUddSUioc550/nPsuIiAbjt2CWU5
         b9WPUpVXBI7i0KzR2sVvvzLO7XckwCqpTAJeoGeNnsCadZi3D5Cgu9/XzRBdqTmwGrtP
         0JJrrLDA1h6Qi/Ip68Em27F/fIOdV2Jdou0jbv3Px8bO5T+2yzFdyAPRZ0Mv8wpsCybM
         WUq2NBPBqm4YVMckGziy5RmdTp+WmUKXxU7F5R0KQ9dQFDcZQwUQWz6NzoEpX3v6jrxH
         gEsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z185si1090349wmb.30.2019.04.18.02.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zn-0001nO-Dg; Thu, 18 Apr 2019 11:06:15 +0200
Message-Id: <20190418084253.811477032@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:27 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: [patch V2 08/29] mm/kmemleak: Simplify stacktrace handling
References: <20190418084119.056416939@linutronix.de>
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
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org
---
 mm/kmemleak.c |   24 +++---------------------
 1 file changed, 3 insertions(+), 21 deletions(-)

--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -410,11 +410,6 @@ static void print_unreferenced(struct se
  */
 static void dump_object_info(struct kmemleak_object *object)
 {
-	struct stack_trace trace;
-
-	trace.nr_entries = object->trace_len;
-	trace.entries = object->trace;
-
 	pr_notice("Object 0x%08lx (size %zu):\n",
 		  object->pointer, object->size);
 	pr_notice("  comm \"%s\", pid %d, jiffies %lu\n",
@@ -424,7 +419,7 @@ static void dump_object_info(struct kmem
 	pr_notice("  flags = 0x%x\n", object->flags);
 	pr_notice("  checksum = %u\n", object->checksum);
 	pr_notice("  backtrace:\n");
-	print_stack_trace(&trace, 4);
+	stack_trace_print(object->trace, object->trace_len, 4);
 }
 
 /*
@@ -553,15 +548,7 @@ static struct kmemleak_object *find_and_
  */
 static int __save_stack_trace(unsigned long *trace)
 {
-	struct stack_trace stack_trace;
-
-	stack_trace.max_entries = MAX_TRACE;
-	stack_trace.nr_entries = 0;
-	stack_trace.entries = trace;
-	stack_trace.skip = 2;
-	save_stack_trace(&stack_trace);
-
-	return stack_trace.nr_entries;
+	return stack_trace_save(trace, MAX_TRACE, 2);
 }
 
 /*
@@ -2019,13 +2006,8 @@ early_param("kmemleak", kmemleak_boot_co
 
 static void __init print_log_trace(struct early_log *log)
 {
-	struct stack_trace trace;
-
-	trace.nr_entries = log->trace_len;
-	trace.entries = log->trace;
-
 	pr_notice("Early log backtrace:\n");
-	print_stack_trace(&trace, 2);
+	stack_trace_print(log->trace, log->trace_len, 2);
 }
 
 /*


