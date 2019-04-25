Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB8F7C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 913A221903
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 913A221903
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B6E36B026B; Thu, 25 Apr 2019 05:59:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F29436B026C; Thu, 25 Apr 2019 05:59:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCCAC6B026D; Thu, 25 Apr 2019 05:59:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 850D46B026B
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:28 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id u19so3838084wmj.5
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=kJJhZXYPA2qJMO1ppX8IXP4MrK33nsCABoVXTwlvXT4=;
        b=XwSc9T9VqCPYKTkFY3gTH41qOVzZN28yJ810tbNi5InsRWtAeVb/esi06/llV6eAah
         TSmGfHJ6NQS0ws6ahmL3dyOet4QD4G9qP5urH9vX4OAUdvT/76+SVkVFy4Nh0Am5N/Ff
         vgtgyTxvwZ55t124q3GmWQo6ZQXMgs63/A7DEcA4kkt2TasYBUcfaabS8MIYrK9N3r8y
         NVD+78gV5TmqCZLMd1xbKQuW9R5sq1Q3EVTNRtMte81IEHnTvg9g0SkJRWNLfnxct1Nv
         bnBo+uMDFoCWCCIHHb0V/Q+ztKLA46agt35ES7FOl7X3URdfIkZ+R+E2YW/zB6QbTHxN
         FJfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVW9lkqMeuuXguIL5OTkeleoomTg7ATxGlBi+OErroZbnVbIP2q
	7hOwtXhaDGRajr17wMXgz2oO3iTGv4t3Pu/b1xa0pIc1OU/sN8hVsT7/+5pkOo11uDWdaf9Di1Q
	BopSqAWdcpZh2VxCJUGlu06dl/a0BSA4W78b5kUUVrYx2CIhmr0Hq64V7vVsIz6sSUQ==
X-Received: by 2002:adf:f405:: with SMTP id g5mr24413714wro.310.1556186367976;
        Thu, 25 Apr 2019 02:59:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5c8zqF3egP98RCoCwnm6QJ47aR+/tKVG1fWg7BRuqP+3LdLtY6BnCYDvwwLt0GBxuL4oy
X-Received: by 2002:adf:f405:: with SMTP id g5mr24413659wro.310.1556186366867;
        Thu, 25 Apr 2019 02:59:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186366; cv=none;
        d=google.com; s=arc-20160816;
        b=mAUJ2GHq9udnD+vqdjLK+yz0TPhgRwzJ0TgVvx8PvjLuDzdvyCR5pxKd0gWCY+F6Se
         qkUMlxg0Kt3OEqLoaDfnEegS8Ik7Yy7anx9uoMxXz5/rDV4gwZxiKvhEUb8eNqCtMmk9
         ezWYjB1HBrkqv8JjDXWZdhkRZ9kc3nO2DA5LXhdmxBrfSUyRPVP2GvWqInB6m++wUf3Q
         /IKpFgDI6NoVZyOCQRUDMJ34507KE9DXVzjhfwjAXTYYRDWzYNzfApfCOV3MFo9zhwdh
         B8DgfndHBWUBR3oIVBKISG3d0CpO42wu4EJtwAVsMi6sy640hmkZJLj8SLwzzCaDYe2+
         1sBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=kJJhZXYPA2qJMO1ppX8IXP4MrK33nsCABoVXTwlvXT4=;
        b=VFBm5ubbf8BcGG6yx1Kzz6qWU1Oj57Q3IchV5ENO+gQhkznw048fbd44/f1qni0XbX
         xH5L1X6AAI0cemmQlScw3xvZnt0CBvjMf+g8clmSl5IFNFlb6jEolhWYOzFuJXdlwkr8
         QYF7J6qWuQ9QSrJutTBnk1bvf14v4CUtdfr30SccNY4+552UPnwXOANeU3TEamxQPg4Y
         XjV7HbrF8W1CUHB/2V8trUDWndl8TqkFFgMm7Fi1d/IC59ZtDqwbTprwXk5YQwlMHrS+
         9vcyMDoLciPa4bL8HgGPRy/RCNZRjVkk33Nbkns7YH4LEkQZUggC31/sF+ZtHRRk57rG
         JN/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x26si15089950wmh.166.2019.04.25.02.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9y-0001sB-TT; Thu, 25 Apr 2019 11:59:19 +0200
Message-Id: <20190425094802.248658135@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:05 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@lst.de>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
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
 Akinobu Mita <akinobu.mita@gmail.com>,
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
Subject: [patch V3 12/29] dma/debug: Simplify stracktrace retrieval
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
Reviewed-by: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
---
 kernel/dma/debug.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

--- a/kernel/dma/debug.c
+++ b/kernel/dma/debug.c
@@ -89,8 +89,8 @@ struct dma_debug_entry {
 	int		 sg_mapped_ents;
 	enum map_err_types  map_err_type;
 #ifdef CONFIG_STACKTRACE
-	struct		 stack_trace stacktrace;
-	unsigned long	 st_entries[DMA_DEBUG_STACKTRACE_ENTRIES];
+	unsigned int	stack_len;
+	unsigned long	stack_entries[DMA_DEBUG_STACKTRACE_ENTRIES];
 #endif
 };
 
@@ -174,7 +174,7 @@ static inline void dump_entry_trace(stru
 #ifdef CONFIG_STACKTRACE
 	if (entry) {
 		pr_warning("Mapped at:\n");
-		print_stack_trace(&entry->stacktrace, 0);
+		stack_trace_print(entry->stack_entries, entry->stack_len, 0);
 	}
 #endif
 }
@@ -704,12 +704,10 @@ static struct dma_debug_entry *dma_entry
 	spin_unlock_irqrestore(&free_entries_lock, flags);
 
 #ifdef CONFIG_STACKTRACE
-	entry->stacktrace.max_entries = DMA_DEBUG_STACKTRACE_ENTRIES;
-	entry->stacktrace.entries = entry->st_entries;
-	entry->stacktrace.skip = 1;
-	save_stack_trace(&entry->stacktrace);
+	entry->stack_len = stack_trace_save(entry->stack_entries,
+					    ARRAY_SIZE(entry->stack_entries),
+					    1);
 #endif
-
 	return entry;
 }
 


