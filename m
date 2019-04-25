Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 104BBC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7BE1206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7BE1206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 064D26B0279; Thu, 25 Apr 2019 05:59:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F29B86B027A; Thu, 25 Apr 2019 05:59:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E40CF6B027B; Thu, 25 Apr 2019 05:59:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 96F816B0279
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:47 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id l1so1708509wme.1
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=AbGWBfsmiBtGe5Q12XU2KARDGzfPBnL23OmriG/Tdzg=;
        b=tm30XNqn3ovaEmLo0MZkjsLVMYMNtmh3BvLFUAFHFZccyuCADT9Q9FB/CHuCM5aJKO
         Yg0NewQU4hptMTLiTShhaI7n0gfRDxfhY0/eLN7XunH76unXmBdu6pO8LPZnYuwXjWT3
         8MuIhr90ADlILiAYV0Ascz6CB9DaLQCEOBAr0DcmgiYYlPoKqPtF/5kTPRJvKfq7T4KY
         1p0cX7L2dXCYvNjJ0ZiZ/WXEL3mCX6lqwA/1gkxzx5UyZBJlPnBsPcKB8/oAJYWdY0Gx
         7RG4+KA6J9miccrpClz9mEsl1NzSJLJ1b+gCFj3lkGUJ4QGAOEKs0qk1JR2ZPS48NdKo
         esUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVq6GYuL4nLkbxXfaQTFeLwDtcyTG6hFCogEaDrBoeYe4UZjO5Y
	k/IUDtNAUyIv1z2q6RSOlnn97nYMjsPQQIfw94UlZ3AQuEBqoUnNGSKkfiNGmDUzffKdOa6+IMs
	m92OnhcGQSmZ9WRAaCh/wTBh9RQz0AULhQZNtWE7UqVzdTguro/YCTKPt2o4Ahu0Jmw==
X-Received: by 2002:a1c:f70c:: with SMTP id v12mr2747557wmh.86.1556186387132;
        Thu, 25 Apr 2019 02:59:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiuxI86MtxfLO6beW0Som5MhFbckgVBTop9Llx5NI02tzpsz7mgHy07ckk1O96us4U4/UY
X-Received: by 2002:a1c:f70c:: with SMTP id v12mr2747504wmh.86.1556186386299;
        Thu, 25 Apr 2019 02:59:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186386; cv=none;
        d=google.com; s=arc-20160816;
        b=ATBaH4SIcIVJ12wbLpma+0iTw8Qi2tkYMw7qohtR72V3PZFbC7AciGbR/RhZVeiYlk
         sDCcXl5Un98FGPXL2RPOATzp8c/56sIPf9ZmjUjtQGiTWFC7DY9FIgDeOGIRZ8KTWjND
         zWR7FdIFRVV+il+P5CXzumQ7ZKOaHg59NLRRj0NV5PuV7DWmQmQnjMYbk9XGurXnCWti
         LAVSOqNJGBWQa4wvgG8lAxBLsYukJJwziSril8R0C8lHpmNCHOaDx4yChOEx+gti27Oj
         mRAbJPyTwNKbHFOnzx3e9jkeVtJp0Ys8nyZjxhYAHMZ5fdYh55VUVCz2/fSWrNS7fWQh
         mrhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=AbGWBfsmiBtGe5Q12XU2KARDGzfPBnL23OmriG/Tdzg=;
        b=xu27a479TVqDmg8ZtKo6EESUt1GpPJmBcpZa8mSZiImDPUwxvDgsqZNLgERkEYL9UU
         tC2TgI3Vgf2D9R+DcE18zXU8LvoVK3s/9wv/kVSXlaT63tNiiF4VJnezW7Jo68JEIB5P
         WavNI6iSBd+2WuzZdtI+8J9yRBQhVM7yrQ25MlCz+y2r7qqWNx8m4xBO06th8HhfHogx
         KRG6PgVxH5HR0U75wB4JVscoD0bpoq2QdnHv7R9wjF4gJdm4279FVsRwqhqR4LOyDkfx
         4M45GBSDQHH+94gC2VLAZTaYTu4PijC1CMw/XyEwH2dZl9h4tyi4XOzppzecLy7uPKRF
         L+2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z23si2940255wml.135.2019.04.25.02.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbAM-0001zT-1S; Thu, 25 Apr 2019 11:59:42 +0200
Message-Id: <20190425094803.524796783@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:19 +0200
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
Subject: [patch V3 26/29] stacktrace: Remove obsolete functions
References: <20190425094453.875139013@linutronix.de>
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
@@ -72,14 +66,6 @@ int stack_trace_snprint(char *buf, size_
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


