Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4CD1C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC297218B0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC297218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 101F46B026A; Thu, 25 Apr 2019 05:59:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2D446B0266; Thu, 25 Apr 2019 05:59:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D809C6B0269; Thu, 25 Apr 2019 05:59:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4736B000E
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:22 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id n6so335855wre.18
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=QesvxAdhNbDpCrwGVxWTyn37DOC2nIpwHMLZVWagzF4=;
        b=pI0v2UBWyshIZ04hdeoBI5JpEraIM9rskIN/bsxWXj12MgnPi+DXZTcNIS/xaHwOJf
         XXCd5oOXTQ9RTxm/JsSESsIKpWN+eW2FPM/Rfow1c39KVhVJvUUFV7ErbK2gY7fil20+
         +aWhgncijghjwM/FQnGbOyo2z56n2+S0RTMxL89nC+SQSjF/rRFaGEYANmloa2EGx1Pb
         UWkoYTdj4tGFb5st3YrcCZc7ZzmOV9ZtI7gwuvDABC0D3YckQJjqLbigZyNv9CAB/k6r
         9iFKFsjh9hg/7bruSy60cAmSdM5b+fQ2K2k9BVT3Fd4mI2+a/1lNysMUJNH0DJBUXztS
         zOMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVf3/80VgUS0cPvZQPfehND+LdJ4xRH6q+WGe+PgJ/SOmu1uxsz
	IUkUIclGbPv0Iov5VgN9Tqo+HsUO0FnJnNThyVlbL0Jt6tGWILwxziLNmN/ks8NGR20hav+vFUz
	7eX0aRhOjh0ZsE5FPhWNMJvhcNe9OBOGVYui9NbTwbnl1NatQn9d+SojAnJ+0pWyA0A==
X-Received: by 2002:adf:fb09:: with SMTP id c9mr2578323wrr.137.1556186362115;
        Thu, 25 Apr 2019 02:59:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznGRdygfVj0B9BtdW3lfFl/HmF3Ll0t12rd72w47tw/QqU+JU8rwBgPnOBlr64sXOoVXbv
X-Received: by 2002:adf:fb09:: with SMTP id c9mr2578266wrr.137.1556186360976;
        Thu, 25 Apr 2019 02:59:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186360; cv=none;
        d=google.com; s=arc-20160816;
        b=Ehc3xhVHa/A6RozmQsiMDeH53ffdzp+kfhgskjFhsC0g1zohldF9jWFyArFiDDx95P
         zt8cxtNCM69exr2WSMBskXjJKgMhqwHnxU1Ubj0uU4swnzJbJZa2X73kiD6FSsW4SCrg
         mblCkSse9us4WF83lrj1foBGpUC6Tz1t0MgwiSVfY4fisFMH450wkG5Pz80Eb7cGWnVd
         MoMrK7WeRaU4+fZ2lLPkm/0PWA1G5qb0kb91/Z1Nm3FU1rUXjE+89xzPrEjRdFFWy+S5
         hsLPcj3Xpd166XpY8pslT1/MYs+IwEn+9wt9Qe7fQM8vmgHszADmoTsrWc95danr7gj6
         I41Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=QesvxAdhNbDpCrwGVxWTyn37DOC2nIpwHMLZVWagzF4=;
        b=uIMI9+yLZNrVjHMDFNPTYS+rcCFAbkpLhLqR3pMcldSBfFh64/p0W9dGonrClwBKvV
         EjpE5KoE5GuPit/RT3f9XwFLNR9kBqYUr6phPxf7vgK1gUJzVrVMm1lS1HI1On8W+l6U
         ripjkHJ0fGC+StnneeeY7KZDJdH8lh16+nacXIIIHRiUoouezTkO7xo2KP00CVKg0m2M
         cyDMUrYA7urcXDEsSqnWuYWMxQzgqox51Qec7A4PDDraGOLxqKKh6CZfa6rWCnNUQPkP
         dm06t9Xu/NVHXPHSgTl6tcNox8WPBMref/iZm1LR/rE7XQIE0v2mtF6TRpALbuh7i9ZT
         o7zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q17si2316172wrr.64.2019.04.25.02.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9p-0001ql-4x; Thu, 25 Apr 2019 11:59:09 +0200
Message-Id: <20190425094801.589304463@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:44:58 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>,
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
Subject: [patch V3 05/29] proc: Simplify task stack retrieval
References: <20190425094453.875139013@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the indirection through struct stack_trace with an invocation of
the storage array based interface.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 fs/proc/base.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -407,7 +407,6 @@ static void unlock_trace(struct task_str
 static int proc_pid_stack(struct seq_file *m, struct pid_namespace *ns,
 			  struct pid *pid, struct task_struct *task)
 {
-	struct stack_trace trace;
 	unsigned long *entries;
 	int err;
 
@@ -430,20 +429,17 @@ static int proc_pid_stack(struct seq_fil
 	if (!entries)
 		return -ENOMEM;
 
-	trace.nr_entries	= 0;
-	trace.max_entries	= MAX_STACK_TRACE_DEPTH;
-	trace.entries		= entries;
-	trace.skip		= 0;
-
 	err = lock_trace(task);
 	if (!err) {
-		unsigned int i;
+		unsigned int i, nr_entries;
 
-		save_stack_trace_tsk(task, &trace);
+		nr_entries = stack_trace_save_tsk(task, entries,
+						  MAX_STACK_TRACE_DEPTH, 0);
 
-		for (i = 0; i < trace.nr_entries; i++) {
+		for (i = 0; i < nr_entries; i++) {
 			seq_printf(m, "[<0>] %pB\n", (void *)entries[i]);
 		}
+
 		unlock_trace(task);
 	}
 	kfree(entries);


