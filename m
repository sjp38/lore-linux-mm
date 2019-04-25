Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C117C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB196218B0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB196218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E5066B0266; Thu, 25 Apr 2019 05:59:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BE256B026B; Thu, 25 Apr 2019 05:59:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE9896B0269; Thu, 25 Apr 2019 05:59:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9860E6B0010
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:23 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id r7so10963537wrc.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=ndPMY5lfafu/EZtXmPJOgPVCY5qMZpY8tacLKTDS9zk=;
        b=R1uaiaJJjZdtbFwLDGfkjKtalV5J6ECJ5shb7PTa+c569UwrCMtJUhwIp4EN0ESBS+
         ihEaUsuvrlnFFpoUeX+u+DtGMWAlNpeY8t/igPd4MYP0xelrqFt+UWVBouZg7I5y0cpZ
         lKeZGHTuBfgb6pzrICSJH6KBZcPY/Dw/2Imx/sMXRl2h4rC49/zzX6Thkt0mqjEXPHt9
         er11ocTSgbGnnS9hLAXCR9C6BMO2ADhw4HTVjFIJLKyUujRwj5nO1qPnUCQspKf17oi0
         K+NzOLMDRL8UNWejj9fkNPdmB2bITriRrfTHrQpWOhUoCCkyztgAYgqNcVHbCcG3hsRb
         hvIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWSl6IHwr2izuDMaEnAy4kDigxH94GFd8omoiBex+mGegAbcyGf
	nNdZaHlI9LGwvYfvt/mn0x6508ErBVA9IcV8rXOYUT/piU6Q75FvUAOnewS489M1paxVXcU8rzn
	0c+dbD14rHFPJUuY9Y56V2X/7l3oAKe0bEH/EDCttsWU01eZI6mRleqK1DLNz2C8z+Q==
X-Received: by 2002:adf:e684:: with SMTP id r4mr11172645wrm.169.1556186363073;
        Thu, 25 Apr 2019 02:59:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyFzmcjgSFFs7ziXWDgu7DRnYCO+nyHBqWVwgoEiWsCHiUhJxtilhtgw2NNQr+BhYqRpKu
X-Received: by 2002:adf:e684:: with SMTP id r4mr11172574wrm.169.1556186361664;
        Thu, 25 Apr 2019 02:59:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186361; cv=none;
        d=google.com; s=arc-20160816;
        b=pRR823lUtQGKKCjJ6sp4vthrs1GIoDqWZMwNx3F6CIRpcAQdrAKd+2Crt2N2awLQ7E
         bdrANlcmTjefiDTKALRX6auNAoHpHWS8QauDuWo9WaYkPyVobFzNAGR++SnNydXeSvfo
         2VTXZ3mDv6YWVyOT9j9bDq2XzogdbBkwXvZkj5x4FFWWJvyRkUBJ3Xi86pOpHnT2Ml2i
         B/XoclufjnJz1ZS2HofJoj34GbPrxcLELIw3UtmArPCxYAzXjYE8IEBSJN5KR4uJpcfH
         hk4PiD3mVHPOTLc0MYmG91vAqH7/rgG+Mr9812Lfa57gssj1ehDkI/cphfFTbUSZqm2P
         RCHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=ndPMY5lfafu/EZtXmPJOgPVCY5qMZpY8tacLKTDS9zk=;
        b=w4IMxoGV1ihoWEwTTSARuFIr8+iObJnHBKzm7srn9JMDU2PvmWCyvIY+4CMOvcj/pl
         g1ancYRniU5tUV9aSiqqIk7ginKLkgPXiv8yUZrLuBzrgrqf6GxViwe0WiBs0aMhveDu
         7litg9dWfzDpiJmQxIagGOSgBSYPsvt5rlvf3MaJHFPmvYmt7xf8FTNZSR00ApxPrpTi
         aiBVHHsse3NEJI71yM0FCy+S1Spugu5FW3uB3ZAjJ0d+FGqK5BinAVxn4imd3w04MvE3
         Uj+fPOegRcjR/Neonm27m2cgv/c/pPJ3HGmChQTEfQdpQnFO4XpXfsrnVgkYJJTe+ikb
         Qkiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 88si15749302wra.283.2019.04.25.02.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9q-0001r1-8n; Thu, 25 Apr 2019 11:59:10 +0200
Message-Id: <20190425094801.683039030@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:44:59 +0200
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
Subject: [patch V3 06/29] latency_top: Simplify stack trace handling
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
---
 kernel/latencytop.c |   17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

--- a/kernel/latencytop.c
+++ b/kernel/latencytop.c
@@ -141,20 +141,6 @@ account_global_scheduler_latency(struct
 	memcpy(&latency_record[i], lat, sizeof(struct latency_record));
 }
 
-/*
- * Iterator to store a backtrace into a latency record entry
- */
-static inline void store_stacktrace(struct task_struct *tsk,
-					struct latency_record *lat)
-{
-	struct stack_trace trace;
-
-	memset(&trace, 0, sizeof(trace));
-	trace.max_entries = LT_BACKTRACEDEPTH;
-	trace.entries = &lat->backtrace[0];
-	save_stack_trace_tsk(tsk, &trace);
-}
-
 /**
  * __account_scheduler_latency - record an occurred latency
  * @tsk - the task struct of the task hitting the latency
@@ -191,7 +177,8 @@ void __sched
 	lat.count = 1;
 	lat.time = usecs;
 	lat.max = usecs;
-	store_stacktrace(tsk, &lat);
+
+	stack_trace_save_tsk(tsk, lat.backtrace, LT_BACKTRACEDEPTH, 0);
 
 	raw_spin_lock_irqsave(&latency_lock, flags);
 


