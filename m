Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53E91C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12543206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12543206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3BEA6B028F; Thu, 18 Apr 2019 05:07:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EC336B0291; Thu, 18 Apr 2019 05:07:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B20E6B0292; Thu, 18 Apr 2019 05:07:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA826B028F
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:07:04 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y189so1537759wmd.4
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:07:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=m0uLU3LRPujTJy61AU5Bi+GjyWpcNWqFl1iAjuUNnqw=;
        b=HmMq42V4ZvB4CfhCk6lOd8g82QaccULcsuLL75DX61Cc3rDvlazYhckSYiHQ58Sv63
         8I/KRj8v5VIO6TUKZGtgCyipIvwF6jRsqfopqGt3fb3CxC9z8vefayk8yeXfNNwmOcNR
         Dc9DxKM7vra5+FEfJOzx2GOuDjNTjmIDJfPf7fMWQNV41d+W9OvVLgtl5Rf4s5RgulWS
         fs7eq/n7o2creYobiG2+NPbkyS8QKkgyNVVrFNW0XtOwTxPiiHa+0dHRGDW8NoxwQ2PR
         iDfTqGcqUlUqz/0Qk+Gmlb/HScl8Ad4EaeAMbGvVhqVHyNvXKZ1K67j1sIpdx5UiZWPG
         bnvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVl3A/Rsk6VXObymN9zU5Ej8/39tO0aGjTIrLQ+LzRcMB/DHe3h
	PkL1hnH5WNNJ9RLJnv6Zd2E9ODy4EOhXaEoLYZiUYz78vfCwEZ2pGOjcKj8vBLyUUWa/gM2YFmX
	ZbHsI47oKgQvB1aIEqX851zQYf6Mb7plpxhbPUfTmOFc4AFAv8Qy7EQzKTGIzR1NM/g==
X-Received: by 2002:adf:b611:: with SMTP id f17mr1787356wre.162.1555578423785;
        Thu, 18 Apr 2019 02:07:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyev1I11FbYoPsoeQMg/tRJGbEpt0OR3wIg1cqKZ3r3wmgjPreKHyXQ3RaUwVLaeT/AKV3U
X-Received: by 2002:adf:b611:: with SMTP id f17mr1787253wre.162.1555578422298;
        Thu, 18 Apr 2019 02:07:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578422; cv=none;
        d=google.com; s=arc-20160816;
        b=RvM4wQy4fIvW4Y6/q46sYZJP65sH7soU+X9uD6AuABDHRF4XZvF87gdyDyuXCbhumQ
         gECf0ufU9oaxE14yePL54D5TOlRSoyjga8W1kYgZtNFhAet9OmfanteUq4BMo80hN1vG
         Z702FZdWrxl5/oG+AzSsgzJAsZkqSLyeOgb/9qFSqRoH/vzwpW14ABNOu5kkUhy0edcK
         238EbvuSWskO7Ms8HO0yNi33ki3EfjDPNkM/yK4MXcHM1eUuAb8hOqfMjD3JPHAbwsHB
         fxlPio5HbcnRjtU/z8Lrm4iD/HAjSc6D6Wx7hdUnMMobQFnehdeuT8CZQaL4zSCaYwYU
         pMUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=m0uLU3LRPujTJy61AU5Bi+GjyWpcNWqFl1iAjuUNnqw=;
        b=meVB7xjSX3qvYJeC+W2n0eAINO0O3v72XrMbl3OgJydR8yGrlZtrg0Q50E8tJKxO8z
         fjXDbQcuh0bYDFHYhCNyhcg+iFWauVOOAyy+77FTcc+OSTBxgitvFG1xQPOyUXCC4qIL
         m6I+ossCUYvVsYtoOTa/swVgaThP0aMkbAkGDUVe7jjfb8UtPlD7KznGm1oCQgblim0U
         SylbZ17F6ZkP8uQYJIUutaBOso5MZ6mtQLPa4i2NthxAGify8Ey2jxfGXM4SJsHHgx2G
         BhhXhRbH+TL24EV44WxMp1RDlhcmQsXw/+Eo04GzKy614kKOorJBbRHMKDSbj0P5N/Pg
         ei4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n7si1052893wmc.96.2019.04.18.02.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:07:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30U-0001zE-8G; Thu, 18 Apr 2019 11:06:58 +0200
Message-Id: <20190418084255.561045203@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:46 +0200
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
Subject: [patch V2 27/29] lib/stackdepot: Remove obsolete functions
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No more users of the struct stack_trace based interfaces.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Alexander Potapenko <glider@google.com>
---
 include/linux/stackdepot.h |    4 ----
 lib/stackdepot.c           |   20 --------------------
 2 files changed, 24 deletions(-)

--- a/include/linux/stackdepot.h
+++ b/include/linux/stackdepot.h
@@ -23,13 +23,9 @@
 
 typedef u32 depot_stack_handle_t;
 
-struct stack_trace;
-
-depot_stack_handle_t depot_save_stack(struct stack_trace *trace, gfp_t flags);
 depot_stack_handle_t stack_depot_save(unsigned long *entries,
 				      unsigned int nr_entries, gfp_t gfp_flags);
 
-void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace);
 unsigned int stack_depot_fetch(depot_stack_handle_t handle,
 			       unsigned long **entries);
 
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -212,14 +212,6 @@ unsigned int stack_depot_fetch(depot_sta
 }
 EXPORT_SYMBOL_GPL(stack_depot_fetch);
 
-void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace)
-{
-	unsigned int nent = stack_depot_fetch(handle, &trace->entries);
-
-	trace->max_entries = trace->nr_entries = nent;
-}
-EXPORT_SYMBOL_GPL(depot_fetch_stack);
-
 /**
  * stack_depot_save - Save a stack trace from an array
  *
@@ -314,15 +306,3 @@ depot_stack_handle_t stack_depot_save(un
 	return retval;
 }
 EXPORT_SYMBOL_GPL(stack_depot_save);
-
-/**
- * depot_save_stack - save stack in a stack depot.
- * @trace - the stacktrace to save.
- * @alloc_flags - flags for allocating additional memory if required.
- */
-depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
-				      gfp_t alloc_flags)
-{
-	return stack_depot_save(trace->entries, trace->nr_entries, alloc_flags);
-}
-EXPORT_SYMBOL_GPL(depot_save_stack);


