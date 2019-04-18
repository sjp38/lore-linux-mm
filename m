Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F888C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E187F206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E187F206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE32B6B0283; Thu, 18 Apr 2019 05:06:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6F7D6B0284; Thu, 18 Apr 2019 05:06:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBF976B0285; Thu, 18 Apr 2019 05:06:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6ACFB6B0283
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:52 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id k17so1527234wrq.7
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=3+9T0z9unofC3pE/39cVnhN7HKt3P3w9oi49TvlpUJ8=;
        b=KfLlasR6bZlVRjWyt55SPVnoEd2TxJ5pmLTa+bS9dAs/XqqITa5XIrkPLOAgwhhgyD
         lBSTqgzy139D07/m2J3L8zlZnOv+VXK8fCIcZXRCKrGUE09d3/1keT/myFLNKOoe0tsH
         ikGy9OBeSbt2XfX60VEuhPhTmC46Ui+p8YU4yd5bn5xOFt9TGEjAN2NJvwryBe8AsrDU
         KUFh9fvQ6aVCwaTdhmlDIzgOMxu1nPZj3llQ7O5mqk26Ct9fDU3Vs9MJVIwaaQ7vvyFN
         PdBouKJOndUKfNZZMVtSgAApKGBnQE+WCtpQ09PoYpG9gJ+8xf52sMfrHdg0LRe+JvhK
         wn+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVzGBHQDBe4EX6w4RmWuoLs88bRCXk/ECYmMIGUYaZB/Wo5M0iX
	y3QVCX4mFBaOXrdkLtlEbv7QugJx+OqR/EiiB0+1uKsH6ayle6UgAp6YGLhLuY0+A3SQg1EmQs3
	QGJPZzazo323lZMWt6rGVkUBEehQvYp0uE48K8MhD1T6CYLveq9l2lhTnG6csSNPzow==
X-Received: by 2002:adf:8051:: with SMTP id 75mr5080751wrk.2.1555578411980;
        Thu, 18 Apr 2019 02:06:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwU0Cdzw441Nuie1pkh0rbGSm0vijjOdsIz+OMz+mbBChLFt0gGKfeh+e+MIt+VIHyRlc7E
X-Received: by 2002:adf:8051:: with SMTP id 75mr5080700wrk.2.1555578411224;
        Thu, 18 Apr 2019 02:06:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578411; cv=none;
        d=google.com; s=arc-20160816;
        b=KlJ3L0rL59/ww9fHFdI2YAA7HEIZYDfDNtuxT+xQ1F9LxNEbP1ZW2c1sRN/nicoWVg
         Gwmwtmu84XoYvuCPP4XF+dpO2y9vMR3ScHeGPPEO3m1WZvZQZnl/9ADn53qd26icuCkk
         LN/VyaodP/tJHRCMV0cGXfKF+7xSR1jmCr3yPLkfIKLLSmEqJa63v6XMZZ0w/Dh92lBj
         /E6hE3ZywHgtGqwBGAnqSADctTRb7bFzSRVBH/VnNea2KByqC9rLE/NtlPsUE6WoPjj9
         v/tk06bcgaTVhrmGhx0piNfUPbYrS8hpb8GYpIzhTBzDBVesgr3+jBkr5+pD2FrUMXIm
         XxvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=3+9T0z9unofC3pE/39cVnhN7HKt3P3w9oi49TvlpUJ8=;
        b=zupzBUmr5wYpRYzXiv7HW/NXP/q3PmJLnTg0q3Ys+/mXws0aysaVvhmmQ+1pVKndi2
         7GgApkRTJraV3M7WJX4LHawnCi9iPo99mXjHmQT0N1Xzlbcp3U8LX6IkXmovX4rnLk+K
         3puHpyVUsUMQRtblgLbN+usRYqLVYoO8tJBSnYnh23seuNeN1IjIZSsd0tXvMPTaYUyi
         KvkOjRZl6z18iHs/xsKrvf6jIzVnNBAyMRJzKiXvAGtS+0uiL4JQ+vFBMXNlK8dml22y
         xiVZTpK0WpMQM5+h7gVeH/uPe/7+tG01ACCQFQX4rYDcnkPw0s6hcaFA0yKy/TlsEMHp
         5MaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w16si1218911wrn.241.2019.04.18.02.06.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30I-0001v7-RI; Thu, 18 Apr 2019 11:06:47 +0200
Message-Id: <20190418084255.088813838@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:41 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
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
Subject: [patch V2 22/29] tracing: Make ftrace_trace_userstack() static and
 conditional
References: <20190418084119.056416939@linutronix.de>
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
Cc: Steven Rostedt <rostedt@goodmis.org>
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


