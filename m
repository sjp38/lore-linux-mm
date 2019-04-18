Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E6B0C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF93C218D3
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF93C218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBEE36B0276; Thu, 18 Apr 2019 05:06:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B49F36B0277; Thu, 18 Apr 2019 05:06:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A39006B0278; Thu, 18 Apr 2019 05:06:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C35F6B0276
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:39 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id b12so5789631wmj.0
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=/+X3jSHweuVn+GxUpQY/TlAKbGiIavnKcuifhQFvNYY=;
        b=daFH4Ht6Q4q82E64mu/YPg/kWfPN55QJ8G9zSttHI23tisr3eyz1q/870uKOVELnH0
         0MiIQ3avcGRwWs4TSFmj5HgNleshLZTpQ06qHAHuHv8rN2Msb/LXe6r/8sWSZUcvaBB1
         mrmL6HNMI5Qb03TGHaqwOcDKNVsnHM1wOl1nc5573YALBEVbXBNbfFzfHbwCqw2YeDZM
         SLu5NVNnZIo4n2WNfjfn5EdihAY57RCPdnbT2bt87NjHCv97a9sKydnB2vh7dmgW9hyE
         9/sxqaF1WJ8U1qgDmCr00lA1u9baOHgeaVmrTxfY/Kpcs+ZCR1SwHUyrRD41AAWQzywm
         E3Ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAV/PKJqC3y/b5wsW7QJRzJGjhzCHmxyzdA7SNw61/HlMMZSWO0K
	+FbARdkt9ZSZhbBMHtTUMvNjJQeGdmWE6BT4+q7G1URgCMUC4raWMSFwmZ2k6OwB2cfUpJjHUEy
	hGguBL85o/9hbqGk3qdrk8sPx4A7MvFzOytTP9NftXRy4OyC8DwP4UGFlZR6o4YS9PA==
X-Received: by 2002:adf:82c9:: with SMTP id 67mr40294792wrc.261.1555578398845;
        Thu, 18 Apr 2019 02:06:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsxrL9z0BhUtkSYVo9hL++a6FhYvwHjT/+lAMfxFGDIY+eYb+DuKbbnUwXyjZF45aDHfm6
X-Received: by 2002:adf:82c9:: with SMTP id 67mr40294727wrc.261.1555578397783;
        Thu, 18 Apr 2019 02:06:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578397; cv=none;
        d=google.com; s=arc-20160816;
        b=B+7pRI7qAy/mRj0fyu60Xkp8IK/Mg2X0HrUvtrlr/mZ41WG60AzTQnXEDUjYYWTaEd
         5dVrJUII9CKfxblMoZ4zABGjuq6tO3eyhGW0t84gHr91oeqnWcLxKCk2qXSp+3lOBuHL
         pNPoYsef9hkIIid0zIxOiPoTitGEJo8IrACvn7A5PttTdzRaaSU6Fv2/s7DE6gqKtk4E
         6RKP+0O0wQnrsNtfWIdDO9BfwaGu9I5vEYh5WfxLoBlCpVhshYx1IQ02aKYbla/iIQHw
         Pnhgwif5aVAshYqk+e0FdfT9qE9boobzg8GLilkMarX6Gs9ua3W/JnHJXCdEqW+3vzXd
         b7aQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=/+X3jSHweuVn+GxUpQY/TlAKbGiIavnKcuifhQFvNYY=;
        b=xfJXewQmzIBS036WZdLqT6/IdqgYvfSNnl2CY5uLRiW7Dj/6AD4hrzHv5ZjhWXU8dX
         AOEw9LeNxORAXXJVzraeUDDPSwF/nBZmje9fmvDOsvZckLSzGh1wg1QeJAIGkVVITzGs
         ZhDD3dlK/rIx7YuBjl0pfe8cZ01aH54IBsupKQjDUbiwJT/5QF8bggouGtKWpvI7PSTQ
         DEN89pGQozLobBcydPGd1kt39yTEMMoy8j4f7/YMeqxwHRYkzNuQ8DAmQ9fwr+VQF0gv
         AcSl2K0eC5CQNlL7cPmzrqmfxeuy3cnVZAQ7dBKhgQvjI3GjYMLc7ImmrgpW5fAeacXB
         Xeig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g62si1085979wmf.93.2019.04.18.02.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH303-0001rK-1g; Thu, 18 Apr 2019 11:06:31 +0200
Message-Id: <20190418084254.459090858@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:34 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
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
 linux-btrfs@vger.kernel.org, intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: [patch V2 15/29] dm persistent data: Simplify stack trace handling
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the indirection through struct stack_trace with an invocation of
the storage array based interface. This results in less storage space and
indirection.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: dm-devel@redhat.com
Cc: Mike Snitzer <snitzer@redhat.com>
Cc: Alasdair Kergon <agk@redhat.com>
---
 drivers/md/persistent-data/dm-block-manager.c |   19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

--- a/drivers/md/persistent-data/dm-block-manager.c
+++ b/drivers/md/persistent-data/dm-block-manager.c
@@ -35,7 +35,10 @@
 #define MAX_HOLDERS 4
 #define MAX_STACK 10
 
-typedef unsigned long stack_entries[MAX_STACK];
+struct stack_store {
+	unsigned int	nr_entries;
+	unsigned long	entries[MAX_STACK];
+};
 
 struct block_lock {
 	spinlock_t lock;
@@ -44,8 +47,7 @@ struct block_lock {
 	struct task_struct *holders[MAX_HOLDERS];
 
 #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
-	struct stack_trace traces[MAX_HOLDERS];
-	stack_entries entries[MAX_HOLDERS];
+	struct stack_store traces[MAX_HOLDERS];
 #endif
 };
 
@@ -73,7 +75,7 @@ static void __add_holder(struct block_lo
 {
 	unsigned h = __find_holder(lock, NULL);
 #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
-	struct stack_trace *t;
+	struct stack_store *t;
 #endif
 
 	get_task_struct(task);
@@ -81,11 +83,7 @@ static void __add_holder(struct block_lo
 
 #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
 	t = lock->traces + h;
-	t->nr_entries = 0;
-	t->max_entries = MAX_STACK;
-	t->entries = lock->entries[h];
-	t->skip = 2;
-	save_stack_trace(t);
+	t->nr_entries = stack_trace_save(t->entries, MAX_STACK, 2);
 #endif
 }
 
@@ -106,7 +104,8 @@ static int __check_holder(struct block_l
 			DMERR("recursive lock detected in metadata");
 #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
 			DMERR("previously held here:");
-			print_stack_trace(lock->traces + i, 4);
+			stack_trace_print(lock->traces[i].entries,
+					  lock->traces[i].nr_entries, 4);
 
 			DMERR("subsequent acquisition attempted here:");
 			dump_stack();


