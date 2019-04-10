Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8965CC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:06:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5365D218D2
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:06:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5365D218D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C83996B0283; Wed, 10 Apr 2019 07:06:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE1766B0284; Wed, 10 Apr 2019 07:06:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA9226B0285; Wed, 10 Apr 2019 07:06:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4B76B0283
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:06:11 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t9so1189756wrs.16
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:06:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=hjDWrpdWylTsMo1MalcIFQCazEKgNe/cCDMg7s/oinM=;
        b=uNpWdt8akUOYS8wiUfh0nB0Rqe/+RqNftexSGNZyaNiPm+yM/dgVcr13kvI/cBSUq+
         wE8fZL2mVerTxqiFlOClKs+bFbephpiw8/KwjXbIvmhwGrp3jQ5IUix+wUWuUQmjgUpa
         qSmmTxu8n8SlCeChMfYLzW4ohvhNTzrljHX1viP2OKpVNNaVaArUv7OMWHltMOXOrgrT
         c4ObJxqfK6kYnelBQizE8mD40vEyreHdoPfir/LBzS/+wQArVr7dLg4yFlBu22b/dd8J
         gG1UyRoSbkelnWZ31mIVYPJkwHYJxvshEOv4qJY+b9HHRJ3BNiuubfotFkmh7w8W8/iY
         fUZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUezrHexga4y/bUz50stNfzzAozBISKXA+CXYvnm6fDZjsHstaU
	S2zG2BJ/iuGoWAUvUyH1bxbHwusevcf6DJQfFZf6qSxWmDbpbgaLRFolFydCjk2duY78e2NsIim
	hK5SEGd3nFnX3nAoQ755ifu8V5yJR+kPXuRClqmOCfG+fYp+ly4hjzfFSOzV+p0A1yA==
X-Received: by 2002:a5d:4751:: with SMTP id o17mr26809183wrs.121.1554894370886;
        Wed, 10 Apr 2019 04:06:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVUpLkX8WSTDYl3ah7z4e+Qq+v7TTWc4QKvOTYp7EHo0ic81YUHYmx3Z1J52/nH+3nmavE
X-Received: by 2002:a5d:4751:: with SMTP id o17mr26809130wrs.121.1554894370075;
        Wed, 10 Apr 2019 04:06:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554894370; cv=none;
        d=google.com; s=arc-20160816;
        b=bnF9WssgTT1Km7tv+XBDi/m7ssvqMvKxN3Ux/IDJU9FucLN13s5LPPDpDoveA73NZx
         IkLc/qB5MNVu0pYrjk3Nkfqne7aU94nDPMFnwC/2oL8hhXYTkX0N85NP8xEY8dBBQ3dO
         FUcpql54XFBGWGOwhF/MGjVsAaLAkoWRxObZkqBgxWYAGh620pL2ftEri3fJGR1ouQgr
         gwWuPmmxLRFK8T4jQz22RTaxjCYVPwChnf+8P1HcMMHa4EakmPLKh6dWX7NpovecI00H
         GdUiTqeb6nubnUGDynTbfjV1tTR2Cu93/JmxNiS95fmB+6pGUE6lhK6dMn1tCht7tO1C
         gWzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=hjDWrpdWylTsMo1MalcIFQCazEKgNe/cCDMg7s/oinM=;
        b=VYA5LPvpaM0SvKLaNvTxcUWPkwbbrhJqKZcFVzHctFT0rAQM3CXITs2a2Q7rj+fuSn
         lvZd1DrdDMwZNv43J8Zy/acBR5+PuUjIC2rjm4qBCOKnwdCflnAyPuunSWlz/Qj0n9QW
         ta8uhdOlFJk4v1oeC3Jq4YouU+TQUsFDb0gu8Wxj/+UEGRpqbQRbHD4yd/CC8S+u51a2
         2u/QXefm7sxJjWwCBeowZj/pI/ceOlFEZlvp8xvWTf+qj++RYHoJg9cbczm/w3VfCR+c
         Yw+7C3E/Sxig7y4r+umX4CFBHH1LhTVmYOPc6OkJ/AU6rPAy+DSa+CCGZcMhHCoNAQN6
         Cugg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b65si1299898wmd.167.2019.04.10.04.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Apr 2019 04:06:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hEB3H-0005AD-H8; Wed, 10 Apr 2019 13:05:59 +0200
Message-Id: <20190410103645.862294081@linutronix.de>
User-Agent: quilt/0.65
Date: Wed, 10 Apr 2019 12:28:19 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com,
 linux-mm@kvack.org
Subject: [RFC patch 25/41] mm/kasan: Simplify stacktrace handling
References: <20190410102754.387743324@linutronix.de>
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
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
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
+	unsigned int nent;
 
-	save_stack_trace(&trace);
-	filter_irq_stacks(&trace);
-
-	return depot_save_stack(&trace, flags);
+	nent = stack_trace_save(entries, ARRAY_SIZE(entries), 0);
+	nent = filter_irq_stacks(entries, nent);
+	return stack_depot_save(entries, nent, flags);
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
+		unsigned int nent;
 
-		depot_fetch_stack(track->stack, &trace);
-		print_stack_trace(&trace, 0);
+		nent = stack_depot_fetch(track->stack, &entries);
+		stack_trace_print(entries, nent, 0);
 	} else {
 		pr_err("(stack is not available)\n");
 	}


