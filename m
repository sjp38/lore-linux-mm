Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F109C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1EC4206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1EC4206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A21B16B026E; Thu, 25 Apr 2019 05:59:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FB276B0270; Thu, 25 Apr 2019 05:59:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 910126B0271; Thu, 25 Apr 2019 05:59:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4072B6B026E
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:34 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id s18so233583wmj.1
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=/+X3jSHweuVn+GxUpQY/TlAKbGiIavnKcuifhQFvNYY=;
        b=BFhEcNMaiKNUQ9iTu7Uj+7MoGu6/pxNhQX9iwJkaC7rihTYpZngfBFrZBLFH6ww6ep
         yzECAO+np36qFWVPFh70v3uk/EWAXv+FPzs0gnoyA2va588MpkWa+o/ePL4J0NsZdifd
         NJ83g7hqaPsoXYY7xMZVjCVtyY12p7Bu0opnJ7fh3Zub98UQyRrDeDsfkIIN50NH2I4f
         7O1DQ3JSja1SkOSg8t7n8Iahq2LC6Tf7SZ/C2/ZaHIJFoJwA7J2t6VYuhrxIyInD6SRt
         JC/kFU9mg7So5zTcW8ZE6GOQ+uTOSrLqQ2qNrWTL/RLIx5YAmU4VwEhey4JpSznpfLgA
         C9Rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVIVlYKDFw/eAkGCMMbIEjwz9jicJsDaK7+F5uVhJcPztaye0fI
	zvNVKwTOEFPE79+ikmV0yGBWvTo3xuTk0xUFmYe9FileXyoWP4GpVQAB5PrHwtkWda/7ah1GqKJ
	kaZpMj/8VPzmo+HLxu2bjkxcrsBFRq4rN2167FAEO2x7rYczLl5z4vJyEwO7udoRHMQ==
X-Received: by 2002:a1c:80c1:: with SMTP id b184mr2841344wmd.109.1556186373790;
        Thu, 25 Apr 2019 02:59:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNHCLLrhVLjD9kEyNuxxO+1GlCy3/taIOOLdF2M6i8TS/5AXWPwT9GPEt6OyihTdkeRmGs
X-Received: by 2002:a1c:80c1:: with SMTP id b184mr2841282wmd.109.1556186372543;
        Thu, 25 Apr 2019 02:59:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186372; cv=none;
        d=google.com; s=arc-20160816;
        b=uDpxwpl0lhP2JsSfdw8cW/yRRs8ndCdW2KEtMUdRsdvW2m9xG4ZGqL6LSF2NQR71jq
         +CSa3RSYxpwC8RwncjSiQ1nxea0mVLR+Pg7QNYe8WJlPDUzT57kWm60xnP6ixtb2j2T4
         qIBd7wOgtvB12IeN6Oaf1cmJEfVp2Pwsw3A2eZnF0L6/mP556kP4C5QbSkTsa9PVMQGI
         rIe1DXs9fOpadZQ4P4IBpmbcZLTTTgZlL4gYEMeLs0oTkDH1fxeqWff50St04nOtQdIl
         7RDCWwud9q/5pVnhMzjB3hcJYk0OFHLiObkHsI5C0hbKimXt5JA4cX/6P/VrP90O2Lss
         whOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=/+X3jSHweuVn+GxUpQY/TlAKbGiIavnKcuifhQFvNYY=;
        b=lN4XzsL9dBaC1x0DZdEP0ub+9L7s3LJONlSYHaCXXMWH86ZD8oTPlKhFNWdRUrxcrT
         p9jiwkn7Xa8YJZEn8b49sZnecm0QWeySZ+FVFHPZXgg3aoEhRLaxWLXc8xH7WlqkrpZi
         2GwS/TLHh+Y2fUXQUEpomGRwGmWQ3FShgolmsuhOh7+oCx2DMruLtIniqez0ZjnUUJNl
         c5bEdn8ShjDoF6apJOM0X000waQFQH6Prguv55J+pE+VS1P8ogk1iEWGxGdUchokZcoo
         vY3ce8mxnafX/WK3iD4av2qwccnsJsxWBiMlHrdZuKH4JizIqEAg5lFAhkrlvbC0j1JT
         E3kA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w7si15061518wmc.15.2019.04.25.02.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbA3-0001t5-BV; Thu, 25 Apr 2019 11:59:23 +0200
Message-Id: <20190425094802.533968922@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:08 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 Steven Rostedt <rostedt@goodmis.org>,
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
 linux-btrfs@vger.kernel.org, Daniel Vetter <daniel@ffwll.ch>,
 intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>,
 Tom Zanussi <tom.zanussi@linux.intel.com>, Miroslav Benes <mbenes@suse.cz>,
 linux-arch@vger.kernel.org
Subject: [patch V3 15/29] dm persistent data: Simplify stack trace handling
References: <20190425094453.875139013@linutronix.de>
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


