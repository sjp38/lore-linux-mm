Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FF05C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADFE6218B0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADFE6218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 010DD6B0005; Thu, 25 Apr 2019 05:59:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F03216B0007; Thu, 25 Apr 2019 05:59:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E19F86B0008; Thu, 25 Apr 2019 05:59:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 94B9F6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:16 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id b12so5714688wmj.0
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=YabZpxn7mRZSzbNRVFW/2KaxGhb8DuUKqYC4gVtFav0=;
        b=YuTecPbdIcBN51NiNMLHuZOiI9pncdrgBOdg1TLlQhdOiSFVl49bvFDcNl7DbzWXOZ
         PwrzLUZ7gG/PpMDBNR+Qt7HM6pU8AGZTRcdoUGQVoWM+lVFnawC6tMPYTHFnTZXiwBgJ
         rugsShF6lQ40DTX3he013c8TGpB6wihaabyGMd+w8f45VGDWkELtp01g7t/t0q3+VL3i
         z0ylDRqzh4IblZM1OuYBxmAy1Tnc3yH59y5QOmnRoRnxCCU/11BhvhKl46fm9GYuV03S
         qLZd+f39s10bf9SDyh4KP/cn0w3OLT22jM8LamzETkHb4DfPC1jwoV5dxDK6Bz2yu6dN
         bFIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUaWdrwDnEF5fCValwWsiuJ+PJxSAiolHKR+XI7fFK8ULYPJ6AU
	vB1Y7K5xIGARsT2UheZHOEDpj+zPJg9ge2C6W6qGtcKOpt2ov9SgC7fImwIIa/5KGgyNOlb+Ecw
	FYYgGNYzqhX7yM11diwvd2bVljJTOD9MAEUeQosWqmzzbtXeGIkjzJI37mWJLgfUpUg==
X-Received: by 2002:a1c:d1c5:: with SMTP id i188mr2852258wmg.8.1556186356103;
        Thu, 25 Apr 2019 02:59:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQqcuDPACjbMbb4QxWUxAl4UZfkGtffPJ5Tx5g0fOBJeDTuSgES7EhL8Hd0hB8sxnGuSc0
X-Received: by 2002:a1c:d1c5:: with SMTP id i188mr2852182wmg.8.1556186354473;
        Thu, 25 Apr 2019 02:59:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186354; cv=none;
        d=google.com; s=arc-20160816;
        b=0wJWOl74aMiyb7jKHPVlBYVpMVg6KiHdy3XTLVUA7+jgQh2oKD/p+JsO/G+2yt+hQU
         9O529LZ/tm0M6uEMCe97zyL5fxkM6EjycfoHG5YUj3/oUDwe4mcArxso2HgOww3eMDMS
         x0MJvxePHhImPnGTAws0JC/1LCjtvnZQXr3zZYDloj04uWERy8LyCXnEQ/8S/ouM/LeZ
         O1jV8/bUFBe6XtaaJaUkAM0CqVrOlsriDpxee/BGTY/7y14aASqF2qAfGj7oZ10+IA9m
         9OGKqudakdYgvsas76OHLcRv+/izS7LhgWbeScDy64LsDhpcv1lSt+gpC7zubzAni9jI
         +ByQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=YabZpxn7mRZSzbNRVFW/2KaxGhb8DuUKqYC4gVtFav0=;
        b=yyRFoqXrPJn88kKBe3VgyZ4Aoad7xv5OIPWwYsPZpBmLduy7US/htf5cuE+hwDQzHH
         k6TfzyfHoS2skBWeyu3Bf9Ge3pmMQiQW+BffxJvY3+WNWNYg8Dbikwi3yOlXlkCyvko3
         qToOXuwIgJcqjtMxNKzTXCS66FjjDQdDSzgEAWsQAZfLGe9flNdbVyF6RfdxNP0tD+iR
         LbZVeyvuNBE9oiOtnDc/AxFwqP6BTzj5fAqhDogO2OVbW309PV8PC+cJfjnppmh9eGpb
         FjDW7L717JOMLeNQwxKd7/qyrOGUrS3mTNpWkwoRcqqHkBaTD8sieg/BOHL8CS88FBM6
         0hmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x7si14932980wmj.16.2019.04.25.02.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9t-0001rM-4A; Thu, 25 Apr 2019 11:59:13 +0200
Message-Id: <20190425094801.863716911@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:01 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>,
 Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org,
 Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
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
Subject: [patch V3 08/29] mm/kmemleak: Simplify stacktrace handling
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
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
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


