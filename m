Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D33EDC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D9AE218EA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D9AE218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FEA46B0289; Thu, 18 Apr 2019 05:06:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D8776B028A; Thu, 18 Apr 2019 05:06:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 779106B028B; Thu, 18 Apr 2019 05:06:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 288016B0289
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:59 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id c8so1527857wru.13
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=MfbypmYEDLOn7xTXPHUvQYPMWvxACXS6VbAX/FlZGRw=;
        b=gnMqrZKwh4UgDxUUiUIRbfccO9SlvIP29tMLfHN5vCVEnXr/Ax08GcXyzMlwpsWSlE
         s7711XofMACs55Pn2SVnltvPtEZqG5zc4VgavARhMDfMBmHrMYacaIISWkOS0E3lr8Qi
         SDKYmqzDFCDmlvwQs7XRcLB5P/4jsDZhLRShcUv4zopkg3l9HlfF07gpES/pTckN6QQh
         xmB+vfXQT91qxYDheZHq53SMQRiGh73FNPbyX8XZRArSD39dZ9n6VUVVMB3dnamG0WiV
         yMoV35pZOmZ7D9ejpRHDEGPTUzSPIQuveaF9D2piqIedizb76oMgh1Pp6axfZ3EmzUUV
         AImA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVQeTkeWusN2yNkG5MAJ6UjMFAUO5Two9xN9v/7n4ii5moC/dhf
	Ua/ozZFvDBliSuEXb6ixt30hxzb4X70ltM3skB8vkfsoljJx/v1fAgLF0LdYrdwAzolnFMGJag2
	YlLqr7JN7DjgYCo9rZInC5L/ImX8L3dTKnWH5EUDmURDfhE9EpIGoNiurBSehP/JJcQ==
X-Received: by 2002:a1c:9ec7:: with SMTP id h190mr2324209wme.105.1555578418669;
        Thu, 18 Apr 2019 02:06:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz87ZTb9fP1JX24EN7J4maaliIPg+mi2mkP1wJWhgCOaUzt7fcKbok5d1ESlIOXf/OTbo6s
X-Received: by 2002:a1c:9ec7:: with SMTP id h190mr2324148wme.105.1555578417778;
        Thu, 18 Apr 2019 02:06:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578417; cv=none;
        d=google.com; s=arc-20160816;
        b=EC/8daHr4Pm4eJChk1/4/D6n+TfDc1dLT8ZfWNmELfZIPS6qIYyLrBZNS/PyI5FjZA
         9YMbjAjMawUyILgVlGOb/HHx9+4mezfhWASUOSjyQ4+mww2VG0jcN93OYF2jWATfoWOn
         AX4q0GGl1/c+2i6AzuHYPUFOZX4QdIN+ct/ScPjv7a8cYxEmhYMNrk44DIURGBtdYcSP
         dWRKDuJ3b1vKY8N8cjZXWR3YI6MrXgjpPsYmFa+wZNhk1/cNCTkjj13thv/PpI6YEbCo
         yGti0CD0D4kdloClq2fBTF062LhUYDSEQa7ypo0m2eH10bF8W1f3LZjpfp/6QiDf8xUu
         PF0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=MfbypmYEDLOn7xTXPHUvQYPMWvxACXS6VbAX/FlZGRw=;
        b=wD/YmI9v4vqASjPSRXAaKuEDup/E3f6Kk3cv05J99jR2a6kD3wcSblpthArRI8QVtV
         Qau8aw7aSkwe/L5DIpF7WIa1paKJjYG9T777U4YZeo+u9jpm4EjsZZW7dYi76hchkA0Y
         zWw//4UZ2NXpPzzm+fGpIv4byivdjwBBF1J19lWhYJfcPja5LIyhKzU7roxoOCZ8xb8h
         CRH4NsBeItpbKtAYMN1epRVnDBuWtLrEHRcg9x3pGhg5aee2kNn25cS5I30X+fTzMjed
         diYie8+V5Z/XDemrO4KrbpkZjqwI2WLU2ygCJva0m1jIovnw/6p/e9G537U7+B4+I9Yk
         Yajg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a6si1068248wmf.82.2019.04.18.02.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zw-0001pi-65; Thu, 18 Apr 2019 11:06:24 +0200
Message-Id: <20190418084254.180116966@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:31 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>, iommu@lists.linux-foundation.org,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>,
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
Subject: [patch V2 12/29] dma/debug: Simplify stracktrace retrieval
References: <20190418084119.056416939@linutronix.de>
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
Cc: iommu@lists.linux-foundation.org
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
---
 kernel/dma/debug.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

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
@@ -704,12 +704,9 @@ static struct dma_debug_entry *dma_entry
 	spin_unlock_irqrestore(&free_entries_lock, flags);
 
 #ifdef CONFIG_STACKTRACE
-	entry->stacktrace.max_entries = DMA_DEBUG_STACKTRACE_ENTRIES;
-	entry->stacktrace.entries = entry->st_entries;
-	entry->stacktrace.skip = 1;
-	save_stack_trace(&entry->stacktrace);
+	entry->stack_len = stack_trace_save(entry->stack_entries,
+					    ARRAY_SIZE(entry->stack_entries), 1);
 #endif
-
 	return entry;
 }
 


