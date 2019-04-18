Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2A33C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C2F4218FD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C2F4218FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C04A6B0266; Thu, 18 Apr 2019 05:06:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 022F86B0008; Thu, 18 Apr 2019 05:06:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2ED26B0010; Thu, 18 Apr 2019 05:06:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91ADE6B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:11 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id y189so1535845wmd.4
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=PNBFVRoc9HP4CIX/Gjc0tnPba+utjyGgJUxB8b6IKHg=;
        b=eBKy6HYZj64UaroAj6ozru0F9Dk8Hfir52nkSNe/P//5TqdNc1CbjYNCEizJN7x9dC
         z3g1OstMx1bHf3jKGQAcjPgcJ+HUxW2NmQba7Fo6+yKtj9o3uJrEimX4f9llv+V/BsJ1
         U8G1NidrMcr9f3QPtl/XrbDoBYhHIx4RFMXG86EPy74zT3DD/0ojiiKLM3ARARNxlnn7
         1HXN5i1DzJyZxhIfu4kD9QATJqHkGb1nI/iyuV+wcQhS/XBhk3fBCcb+cYMj2Sqy1/Sl
         FZsb7l6wTM58wSfmAM71Rxy4VSZEO91LxEfcs3785pK0RHohs4Wic1x0FRRRbtkujj3h
         AGPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVDIf7I5Fnwa4vezY5rNGoLbGE5OJoWy5JWD/cxY4vub5yfA6Z3
	P50o0JB/7RufR+R42dSNfSw0wLVb5eHvXoP1S407VAneMiOFu6aoD+7JHiyHEpV6gydqDRTS2d2
	W7A4nSGYf8M2LPPx2jAIfJ9+EfJYC+tdDQm/u+OEwrHCsm4uW8+SdKdIFJvANXWn82A==
X-Received: by 2002:a7b:c353:: with SMTP id l19mr2134155wmj.12.1555578370896;
        Thu, 18 Apr 2019 02:06:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzL7egUYu5e77MqJ1YlXin2jUbd2N560tiI9+gP/nylVUFAUN730DgAddPJM5xUTNA5e4gC
X-Received: by 2002:a7b:c353:: with SMTP id l19mr2134075wmj.12.1555578369800;
        Thu, 18 Apr 2019 02:06:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578369; cv=none;
        d=google.com; s=arc-20160816;
        b=m0EWcuQgfuRVVjSrPJD5iQb0Q89Okvvq+c3tkN4Ae5bywx/5wM+ogUisD6zFysuKHr
         L3yq2z92p2EhDOxepbN3BVG8MMsh31fCLls0x5vn3dUSncRmE42aO1WXxdwVusdSmD2s
         3qFtiCFjbQLYDs9JiGeSeugqQsGr0o4XIpZyOPv89nMbsb5mTrOdrSLwYS0Sm7sqp58H
         U+Dxg010ZUpxE9MKAKxfUINXKklVindb9CJjIx2gMcqsR9AIdAaDGGfQ1MvVHK5t42qt
         a0nXl5OqV7p5iCzOD2Q5pNFuV9UznIVoyfTdGyyemrqpN3G6YgubINJQVEkBkOZVgM0Q
         rQ+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=PNBFVRoc9HP4CIX/Gjc0tnPba+utjyGgJUxB8b6IKHg=;
        b=OLQcsIOETfCWuP8A9Co6sraaAA5NdNFeDNPWaVepfnFogVkGCrzbDNYaPx58sIdNLZ
         bYm64vL6r+s76xYHqNkY5crmNNR6QIq9wgdcSxujvFvmb0/QD+Bf8FDA5CCsTsY7fv5o
         DwkZcJsOPHQGAqGlXPxY5AwNm8RLQK4KnnZEJH/XuTwEgTnS+2lH+bDD4gIiXvg0vmet
         7pEJBzus3ozUs17N/aG8YcsBY9FBhDbq90SvztE3kDIfTuxi8K0pkRd3sTDcmoUnsBDY
         hDyiu/zX1UZFXLS29vo+XJzz0/W8x/O+G0ZXnII1uouWHq8XKx41N0c+roMF2IrqE3gj
         ZgQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z2si1253992wrp.169.2019.04.18.02.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zZ-0001lv-2D; Thu, 18 Apr 2019 11:06:01 +0200
Message-Id: <20190418084253.142712304@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:20 +0200
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
Subject: [patch V2 01/29] tracing: Cleanup stack trace code
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

- Remove the extra array member of stack_dump_trace[]. It's not required as
  the stack tracer stores at max array size - 1 entries so there is still
  an empty slot.

- Make variables which are only used in trace_stack.c static.

- Simplify the enable/disable logic.

- Rename stack_trace_print() as it's using the stack_trace_ namespace. Free
  the name up for stack trace related functions.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Rostedt <rostedt@goodmis.org>
---
V2: Add more cleanups and use print_max_stack() as requested by Steven.
---
 include/linux/ftrace.h     |   18 ++++--------------
 kernel/trace/trace_stack.c |   36 ++++++++++++------------------------
 2 files changed, 16 insertions(+), 38 deletions(-)

--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -241,21 +241,11 @@ static inline void ftrace_free_mem(struc
 
 #ifdef CONFIG_STACK_TRACER
 
-#define STACK_TRACE_ENTRIES 500
-
-struct stack_trace;
-
-extern unsigned stack_trace_index[];
-extern struct stack_trace stack_trace_max;
-extern unsigned long stack_trace_max_size;
-extern arch_spinlock_t stack_trace_max_lock;
-
 extern int stack_tracer_enabled;
-void stack_trace_print(void);
-int
-stack_trace_sysctl(struct ctl_table *table, int write,
-		   void __user *buffer, size_t *lenp,
-		   loff_t *ppos);
+
+int stack_trace_sysctl(struct ctl_table *table, int write,
+		       void __user *buffer, size_t *lenp,
+		       loff_t *ppos);
 
 /* DO NOT MODIFY THIS VARIABLE DIRECTLY! */
 DECLARE_PER_CPU(int, disable_stack_tracer);
--- a/kernel/trace/trace_stack.c
+++ b/kernel/trace/trace_stack.c
@@ -18,8 +18,10 @@
 
 #include "trace.h"
 
-static unsigned long stack_dump_trace[STACK_TRACE_ENTRIES + 1];
-unsigned stack_trace_index[STACK_TRACE_ENTRIES];
+#define STACK_TRACE_ENTRIES 500
+
+static unsigned long stack_dump_trace[STACK_TRACE_ENTRIES];
+static unsigned stack_trace_index[STACK_TRACE_ENTRIES];
 
 /*
  * Reserve one entry for the passed in ip. This will allow
@@ -31,17 +33,16 @@ struct stack_trace stack_trace_max = {
 	.entries		= &stack_dump_trace[0],
 };
 
-unsigned long stack_trace_max_size;
-arch_spinlock_t stack_trace_max_lock =
+static unsigned long stack_trace_max_size;
+static arch_spinlock_t stack_trace_max_lock =
 	(arch_spinlock_t)__ARCH_SPIN_LOCK_UNLOCKED;
 
 DEFINE_PER_CPU(int, disable_stack_tracer);
 static DEFINE_MUTEX(stack_sysctl_mutex);
 
 int stack_tracer_enabled;
-static int last_stack_tracer_enabled;
 
-void stack_trace_print(void)
+static void print_max_stack(void)
 {
 	long i;
 	int size;
@@ -61,16 +62,7 @@ void stack_trace_print(void)
 	}
 }
 
-/*
- * When arch-specific code overrides this function, the following
- * data should be filled up, assuming stack_trace_max_lock is held to
- * prevent concurrent updates.
- *     stack_trace_index[]
- *     stack_trace_max
- *     stack_trace_max_size
- */
-void __weak
-check_stack(unsigned long ip, unsigned long *stack)
+static void check_stack(unsigned long ip, unsigned long *stack)
 {
 	unsigned long this_size, flags; unsigned long *p, *top, *start;
 	static int tracer_frame;
@@ -179,7 +171,7 @@ check_stack(unsigned long ip, unsigned l
 	stack_trace_max.nr_entries = x;
 
 	if (task_stack_end_corrupted(current)) {
-		stack_trace_print();
+		print_max_stack();
 		BUG();
 	}
 
@@ -412,23 +404,20 @@ stack_trace_sysctl(struct ctl_table *tab
 		   void __user *buffer, size_t *lenp,
 		   loff_t *ppos)
 {
-	int ret;
+	int ret, was_enabled;
 
 	mutex_lock(&stack_sysctl_mutex);
+	was_enabled = !!stack_tracer_enabled;
 
 	ret = proc_dointvec(table, write, buffer, lenp, ppos);
 
-	if (ret || !write ||
-	    (last_stack_tracer_enabled == !!stack_tracer_enabled))
+	if (ret || !write || (was_enabled == !!stack_tracer_enabled))
 		goto out;
 
-	last_stack_tracer_enabled = !!stack_tracer_enabled;
-
 	if (stack_tracer_enabled)
 		register_ftrace_function(&trace_ops);
 	else
 		unregister_ftrace_function(&trace_ops);
-
  out:
 	mutex_unlock(&stack_sysctl_mutex);
 	return ret;
@@ -444,7 +433,6 @@ static __init int enable_stacktrace(char
 		strncpy(stack_trace_filter_buf, str + len, COMMAND_LINE_SIZE);
 
 	stack_tracer_enabled = 1;
-	last_stack_tracer_enabled = 1;
 	return 1;
 }
 __setup("stacktrace", enable_stacktrace);


