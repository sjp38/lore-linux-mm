Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24B68C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D37F1206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D37F1206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 640076B028D; Thu, 18 Apr 2019 05:07:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C9486B028F; Thu, 18 Apr 2019 05:07:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46E386B028E; Thu, 18 Apr 2019 05:07:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB11A6B028F
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:07:00 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id s3so360167wrw.21
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:07:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=/5xTOz92ynxAhyjYrdXulLIkXELWdxy++vIO1sJln64=;
        b=fTEFMGcOuFRrEof4YQOyFScsG0uG9sX4T//9lobQqEnRPqbpz3EvvymoweikYXIT7X
         iVsn0hArLdMPFwjQc94nmlvxfnd0gHr5bvVH+qxNas7zuazNpt3GEdBQ6rXtfI/oa9Ma
         LY0DEYqfk/t0GhMGXVROE9tjAq9Y1Gs5FIqCiAIIgRrpxvg5HKgeLrC7M3aZZHBryE2I
         qB08bAxzaF3OPVQBwGutVFMozQh+rZA0d9VCuWRjmcAfPZqtd6XGC6a1J60AKb9uYPB0
         AhMGMpHwFfow8CUj83NdEzgPf/lEKEA07CR6r1p/vxxzclJ9VzC6pg3ysBOkoYzeZ02Q
         Dx2g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXqR9dBpSrbHFIw/kts+6043B67JqU85OxqyY+6O32oDgYsa0Gy
	PFwOhBimJMic4YpqGLFO13G4KDywTxeN43SRaiXrn/Q82wY+4MzJACtZ1jKjT/4Qm32oFxbENJ3
	VatyXSPIbZ3jHgz2x/LmuMJmcG2AUz6q+PN8/xiykzYOOfb1le45zRQUy26Cc14g2uQ==
X-Received: by 2002:a1c:c18d:: with SMTP id r135mr2174492wmf.112.1555578420480;
        Thu, 18 Apr 2019 02:07:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyKi/hRAcb97ak3fZOVtzgXnq/SWSnJ3WFaxqq2c43JsYp1Is4sIoUA1sqIWNSUy9BkWiD
X-Received: by 2002:a1c:c18d:: with SMTP id r135mr2174453wmf.112.1555578419701;
        Thu, 18 Apr 2019 02:06:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578419; cv=none;
        d=google.com; s=arc-20160816;
        b=hhoYjMYI8/0Ds5sXGdK0VAZUP9pVcVHOiRCvMALYkV8wd6K8PVt01OX6GVI3/93Oaj
         HmrbstGe3sjdMVkZucexm48TepxhKEBxpLfvIi0IG8h2hco0T19khDYT3L67jnDL+txG
         61gbGk5pz3w36TPT8bGPQ+yO4KE2R5mu6lcsib+0zC19U8VCpbDQNFj9jLvKjwrtwCyt
         Y1bFdTGzdqiCBjHoeX+RpMkULq5Hj5JJGeFaW/uL/n+F0bmfO3nkLW3f9r7XfeULKbF3
         2SQydx5lTyiZ2OeMnoZ4pEknQYSvxn2NV8AuA2mBJgxbpxcGYh4CS4ZEwc4s/nz6KJUx
         g2FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=/5xTOz92ynxAhyjYrdXulLIkXELWdxy++vIO1sJln64=;
        b=fsA9ykMv5yh2tzFLo6o9YQRVlysbdzjrscKPA4jAmxKp8JYHNB7RIgH1vlX/y3WdNI
         rsr+wruVKZn9aEe7nxJnscGdJOSFIhajzcgReZzArvrSpZQeRkStlpQYmPyVpuFVS9Ke
         S0bNnRuZEss5pW66b7TmastaAiE19cq1zVcNLq7dsLHglyTPzB9wh1km+acwNFqeQyut
         rTRxKA3jdC6E9sqJLgFxpI6pHF8esqGFFKoK39QA5PHvpFIYk+R0kPCMa1DzDxrIF6JN
         inJWbaRRyz1MROpfsQr09oCsfueaXvP0YnMLNDv5YpkZsgFAgWEORvx4ihsw96xlbO+N
         3/+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v10si1226069wrt.101.2019.04.18.02.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30R-0001y0-Gu; Thu, 18 Apr 2019 11:06:55 +0200
Message-Id: <20190418084255.471038924@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:45 +0200
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
Subject: [patch V2 26/29] stacktrace: Remove obsolete functions
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No more users of the struct stack_trace based interfaces. Remove them.

Remove the macro stubs for !CONFIG_STACKTRACE as well as they are pointless
because the storage on the call sites is conditional on CONFIG_STACKTRACE
already. No point to be 'smart'.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/stacktrace.h |   17 -----------------
 kernel/stacktrace.c        |   14 --------------
 2 files changed, 31 deletions(-)

--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -36,24 +36,7 @@ extern void save_stack_trace_tsk(struct
 				struct stack_trace *trace);
 extern int save_stack_trace_tsk_reliable(struct task_struct *tsk,
 					 struct stack_trace *trace);
-
-extern void print_stack_trace(struct stack_trace *trace, int spaces);
-extern int snprint_stack_trace(char *buf, size_t size,
-			struct stack_trace *trace, int spaces);
-
-#ifdef CONFIG_USER_STACKTRACE_SUPPORT
 extern void save_stack_trace_user(struct stack_trace *trace);
-#else
-# define save_stack_trace_user(trace)              do { } while (0)
-#endif
-
-#else /* !CONFIG_STACKTRACE */
-# define save_stack_trace(trace)			do { } while (0)
-# define save_stack_trace_tsk(tsk, trace)		do { } while (0)
-# define save_stack_trace_user(trace)			do { } while (0)
-# define print_stack_trace(trace, spaces)		do { } while (0)
-# define snprint_stack_trace(buf, size, trace, spaces)	do { } while (0)
-# define save_stack_trace_tsk_reliable(tsk, trace)	({ -ENOSYS; })
 #endif /* CONFIG_STACKTRACE */
 
 #if defined(CONFIG_STACKTRACE) && defined(CONFIG_HAVE_RELIABLE_STACKTRACE)
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -30,12 +30,6 @@ void stack_trace_print(unsigned long *en
 }
 EXPORT_SYMBOL_GPL(stack_trace_print);
 
-void print_stack_trace(struct stack_trace *trace, int spaces)
-{
-	stack_trace_print(trace->entries, trace->nr_entries, spaces);
-}
-EXPORT_SYMBOL_GPL(print_stack_trace);
-
 /**
  * stack_trace_snprint - Print the entries in the stack trace into a buffer
  * @buf:	Pointer to the print buffer
@@ -70,14 +64,6 @@ int stack_trace_snprint(char *buf, size_
 }
 EXPORT_SYMBOL_GPL(stack_trace_snprint);
 
-int snprint_stack_trace(char *buf, size_t size,
-			struct stack_trace *trace, int spaces)
-{
-	return stack_trace_snprint(buf, size, trace->entries,
-				   trace->nr_entries, spaces);
-}
-EXPORT_SYMBOL_GPL(snprint_stack_trace);
-
 /*
  * Architectures that do not implement save_stack_trace_*()
  * get these weak aliases and once-per-bootup warnings


