Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB324C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DA7A206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DA7A206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F8356B0274; Thu, 25 Apr 2019 05:59:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AA5F6B0275; Thu, 25 Apr 2019 05:59:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FB256B0276; Thu, 25 Apr 2019 05:59:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3B566B0274
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:40 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id t9so20481995wrs.16
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=YyoaysuntdWse+rzlTM8zXy679ccU9UxwPcaNstXB8E=;
        b=IVYvX7UlRLj97Se8dsWxNszEKse5U1Pk3Cgxcs0CF9Cx4VGElwDv8najCxnkEPq85h
         PawmrmqGdBDi3Gjqh3s6iJCzwkkMITyhZPDNPbYVX00kWFmJlprCuqhTCH+aCW5s27eS
         p+Om3LNCcX883OPlGm8Byg7ztYVpxl9ASpYHYuqw/zhzvkFCs68CLZEP5msiolXkEWhI
         KsHXEYntfKGrZ3hCkJLQnSwzfyUDrBECHPXMTOxlYMuDWtrQyDcVAS2AkZX9m4Ul9G3Y
         HCyIkN+2PGugOF3YLM5er6O2PLRditBfF5Q7dFedrFMTauk0HU8F+DBUUxnTAedJozcW
         4QsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVEOGhqr8ojAAwLNdZmh6hqBufawM+e71NTwK68xqajCDxfwvf7
	jG/dfIqNbebrWrd6gdSMDqbYd3Na2XESZAYQvK/YXel55SsQ3Wo0bGRErZzEIqK5FaWVGu0Gakh
	bDO1/cEtCmkbr94Jr/xTF5EXzLidSLo4BurKHY+TaFZoFhKzs7iEjMw+EB+zebW/ZSQ==
X-Received: by 2002:a5d:6291:: with SMTP id k17mr26240628wru.223.1556186380272;
        Thu, 25 Apr 2019 02:59:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUrVvrvyrP3UPcI8V03waNwPXXdPhNr7GD8te+hngnaHFbwutLll6QrRk9xWpE09D6npgx
X-Received: by 2002:a5d:6291:: with SMTP id k17mr26240585wru.223.1556186379435;
        Thu, 25 Apr 2019 02:59:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186379; cv=none;
        d=google.com; s=arc-20160816;
        b=V5U9rEx2Z+VAftvvpEqGNavjS30KVQz+XEKmYJJgTSpxEmy9OvWTIHJt6DafsQAp1e
         olmO51pBWs/htSXWDFPUbvfw03i8aUK5N1OabG3IbXcLONV8qKB67hHzuyGd1nGTtfpx
         ZvynEky6EPOX5Ownfkj2DJRJgY0B4AewPY6iMU9H1xkpS74BOkGUtd2zKxQrS9PGOjN8
         702HmOStEKPOAE7Itvpgeb4PTPmWju7JcjieGASmdLxgfGxgSe9OQJNX5z8fj1TmEtL6
         8uisiC8AfPA/6pOZvjqXDFouErdX3S/zY8xFd0RXaHS0FwVC3wGgOIbnOFv2taLRLbrp
         fi4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=YyoaysuntdWse+rzlTM8zXy679ccU9UxwPcaNstXB8E=;
        b=QVIz4/o/5JDxgqIXVY5pJzci6gBjRup7HRL9WuvznoKpYWE/QncxHouGoiUWvE5KBY
         UUz6YExD6XVbtUYC1lnjVNNmvCHBJf9S0i3Y4ZiiWwKS3QuREIo6BRN+vlMNm8mXFx2h
         28w+3zSc95dViKm564GVCKO/KNAPMEjHmOq7pFdOGMzgtM2e+HSfkodbWbX+fUeRbQX/
         E5EykEIRCjQ1+XrxLFp9ticrPQ30lzlNbJd/USSX35OchDhh/pgVRnVI3XEzTJ1JmP4a
         rj4Os1h7KKYo9JCk7TjL4Mm+hCSKGt9d+/G0Qau67My40px7YSdL/h2PTao24cwYkngA
         J8Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v7si15802782wrw.367.2019.04.25.02.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbAF-0001xP-E1; Thu, 25 Apr 2019 11:59:35 +0200
Message-Id: <20190425094803.162400595@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:15 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 linux-mm@kvack.org, David Rientjes <rientjes@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
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
Subject: [patch V3 22/29] tracing: Make ftrace_trace_userstack() static and
 conditional
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It's only used in trace.c and there is absolutely no point in compiling it
in when user space stack traces are not supported.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Steven Rostedt <rostedt@goodmis.org>
---
 kernel/trace/trace.c |   14 ++++++++------
 kernel/trace/trace.h |    8 --------
 2 files changed, 8 insertions(+), 14 deletions(-)

--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -159,6 +159,8 @@ static union trace_eval_map_item *trace_
 #endif /* CONFIG_TRACE_EVAL_MAP_FILE */
 
 static int tracing_set_tracer(struct trace_array *tr, const char *buf);
+static void ftrace_trace_userstack(struct ring_buffer *buffer,
+				   unsigned long flags, int pc);
 
 #define MAX_TRACER_SIZE		100
 static char bootup_tracer_buf[MAX_TRACER_SIZE] __initdata;
@@ -2905,9 +2907,10 @@ void trace_dump_stack(int skip)
 }
 EXPORT_SYMBOL_GPL(trace_dump_stack);
 
+#ifdef CONFIG_USER_STACKTRACE_SUPPORT
 static DEFINE_PER_CPU(int, user_stack_count);
 
-void
+static void
 ftrace_trace_userstack(struct ring_buffer *buffer, unsigned long flags, int pc)
 {
 	struct trace_event_call *call = &event_user_stack;
@@ -2958,13 +2961,12 @@ ftrace_trace_userstack(struct ring_buffe
  out:
 	preempt_enable();
 }
-
-#ifdef UNUSED
-static void __trace_userstack(struct trace_array *tr, unsigned long flags)
+#else /* CONFIG_USER_STACKTRACE_SUPPORT */
+static void ftrace_trace_userstack(struct ring_buffer *buffer,
+				   unsigned long flags, int pc)
 {
-	ftrace_trace_userstack(tr, flags, preempt_count());
 }
-#endif /* UNUSED */
+#endif /* !CONFIG_USER_STACKTRACE_SUPPORT */
 
 #endif /* CONFIG_STACKTRACE */
 
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -782,17 +782,9 @@ void update_max_tr_single(struct trace_a
 #endif /* CONFIG_TRACER_MAX_TRACE */
 
 #ifdef CONFIG_STACKTRACE
-void ftrace_trace_userstack(struct ring_buffer *buffer, unsigned long flags,
-			    int pc);
-
 void __trace_stack(struct trace_array *tr, unsigned long flags, int skip,
 		   int pc);
 #else
-static inline void ftrace_trace_userstack(struct ring_buffer *buffer,
-					  unsigned long flags, int pc)
-{
-}
-
 static inline void __trace_stack(struct trace_array *tr, unsigned long flags,
 				 int skip, int pc)
 {


