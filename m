Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FDB4C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E52D7218D3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E52D7218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D31136B0270; Thu, 25 Apr 2019 05:59:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE1976B0271; Thu, 25 Apr 2019 05:59:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5C4A6B0272; Thu, 25 Apr 2019 05:59:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7876B0270
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:35 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id u19so3838283wmj.5
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=2k7lB3zYSqZ589filPfBZRV80I08rj+3gKaU91f/H30=;
        b=KynXkcsYLx6l/vACjoHkGe98r7SSW8Z8/DhiL338CKmK8Z/kGIKMn4tRIR0/VCx77w
         RlYdCsXzR7P+MVUNy0VnvJf0YL6OOZPD/ITrJAdENH7efLbwQIWUxEvqYgWVl4KGijXk
         Rp3m7TgbQjnJogBbu4EQbvD9nToH2+RViBSXmREbwTvG0qQu84clRjWpw9jcEyx4dqRo
         aCrStAmejzHzXC5N/uzqAeUsSpXyB4esVZTx1uFnqUIJra1DcBOq/14AIgc2tlhcJkpq
         Yn+oYIJxLOIZ06gvKPidUup6HPhQ3qIH+kNP0cs67OtOwNRtSsftl9qYogK6dsjAIe0A
         jfYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWDAIMx4hM6emHh13Ju9o89HUHrhzdDD679aqL57ZYmx9r+n1dI
	4s/bmav9H+Ofan24zEN7ZCoorADI8PAU+DuRAQH4O0KmvX8pU+FE6azpSgOmkYFjBsoT1FhMxPM
	I8mpu/z9u4fnZnkaUFVrPpwXvkFBRrHtwPHt53WmapV8H7B4g67WX6htnq5r6sr7QiA==
X-Received: by 2002:a05:6000:cc:: with SMTP id q12mr14285544wrx.251.1556186374933;
        Thu, 25 Apr 2019 02:59:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ4XTLAy0T42SZ7d20gu4KYdDN4rN7HKSYkltRw08iJ7iZSp3Y8EJVNCQdDGgATX61mhWg
X-Received: by 2002:a05:6000:cc:: with SMTP id q12mr14285492wrx.251.1556186374107;
        Thu, 25 Apr 2019 02:59:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186374; cv=none;
        d=google.com; s=arc-20160816;
        b=UOC+/JMi1qJSsH8NHpnz1EDioDLk86ZfbaOGnoMh1y8EiwRCDb7j7s9LcKCZ7zzPuw
         AsGq0ZGuTCqN0+oTCR9q4VO2TbfK4xnFtlGyhjNoujBsjrvnTF3Y+FiLfPu7ZJUFpIhQ
         2fHHZQaplv3bD3Nuh8++kQJwSRk4wJqyevItq2W1Yj79HUzLpwUG1u99qeybonV80bLE
         Mm/36lN6915cHTU9SttWUy8Syt45Qh+64/2omjSAgwcsYIWaDam+ENbDz6Ht9XObDWjD
         aqFJ1sRicu4JlzRzRGNTSw+172kWUJ5peDl+Pli5auGfCSONRBNQ0otFvsjrZfV6+iLp
         v88g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=2k7lB3zYSqZ589filPfBZRV80I08rj+3gKaU91f/H30=;
        b=VJp7jHrw2ZuLhan+OuTXwNlE3zsFVFkjsSgUd/NfKD3Tpq0SG9FKSUaskDD8WMXked
         7MVdldctptS5l41CFqBZe9P/k03seG7l4WBmHW+7xpYSfc0UWIXjYOZziO6x3A6OJF2y
         UovY4am8tE5c7MzaTGqwHaiJo13mVjUMoxpgES9C4p77B3IDdQmq7LuEKTxSiZjXTsHp
         BrBlyXGZYa0o95mZqtHWp1LIJoqNMU6jpS9zsfbEoUNEu5b5PBykhf1AkGGu9v0DyVN/
         nS0aNuwGGq2/MJ4EJcxZHiCwfwlVyO+2B0bmuCfr+muQlxdtTxqvMNLcJLJnWmI0E7Ih
         QPEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b144si1903237wmd.20.2019.04.25.02.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbA8-0001us-4y; Thu, 25 Apr 2019 11:59:28 +0200
Message-Id: <20190425094802.803362058@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:11 +0200
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
Subject: [patch V3 18/29] lockdep: Remove save argument from check_prev_add()
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There is only one caller which hands in save_trace as function pointer.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 kernel/locking/lockdep.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2158,8 +2158,7 @@ check_deadlock(struct task_struct *curr,
  */
 static int
 check_prev_add(struct task_struct *curr, struct held_lock *prev,
-	       struct held_lock *next, int distance, struct stack_trace *trace,
-	       int (*save)(struct stack_trace *trace))
+	       struct held_lock *next, int distance, struct stack_trace *trace)
 {
 	struct lock_list *uninitialized_var(target_entry);
 	struct lock_list *entry;
@@ -2199,11 +2198,11 @@ check_prev_add(struct task_struct *curr,
 	if (unlikely(!ret)) {
 		if (!trace->entries) {
 			/*
-			 * If @save fails here, the printing might trigger
-			 * a WARN but because of the !nr_entries it should
-			 * not do bad things.
+			 * If save_trace fails here, the printing might
+			 * trigger a WARN but because of the !nr_entries it
+			 * should not do bad things.
 			 */
-			save(trace);
+			save_trace(trace);
 		}
 		return print_circular_bug(&this, target_entry, next, prev);
 	}
@@ -2253,7 +2252,7 @@ check_prev_add(struct task_struct *curr,
 		return print_bfs_bug(ret);
 
 
-	if (!trace->entries && !save(trace))
+	if (!trace->entries && !save_trace(trace))
 		return 0;
 
 	/*
@@ -2318,7 +2317,8 @@ check_prevs_add(struct task_struct *curr
 		 * added:
 		 */
 		if (hlock->read != 2 && hlock->check) {
-			int ret = check_prev_add(curr, hlock, next, distance, &trace, save_trace);
+			int ret = check_prev_add(curr, hlock, next, distance,
+						 &trace);
 			if (!ret)
 				return 0;
 


