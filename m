Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 488B7C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06CDD206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06CDD206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5496A6B027A; Thu, 25 Apr 2019 05:59:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C9466B027B; Thu, 25 Apr 2019 05:59:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 390D96B027C; Thu, 25 Apr 2019 05:59:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id E36406B027A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:50 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id b133so5296633wmg.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=dtwsC8n4B8GouCY2f1douEN0y/UMZvMUJmpbBiyuz7o=;
        b=mhuuAUbANNu/SqvbAygpL7pXBuB/dGudlq8yGqDVOjqMsz2viKaRvY1T5NMFeznfoZ
         OAnGDwJGepvWt8FCKlxhlU0NCfOY3PYkuthd8xOzDc2J44RTDpRwacuGiNnMWAjvO9U8
         qOcOtPZbIzAX6nzXANZ4p5tEO0miB3BYNxRImt+0x1jBTKtjuDfSEvaavzDOF/4P9a05
         eNJw7n0pOgLtqQ8eezVVzFWFyPa148+DfoUSTyhsfhuxpozlZjrvd51aYJOo/Eo+iZrI
         Vzr9xsawWFu/sjb++AI2o6M4tThSqYMz3XEZ3J3jsY+JvSiGmQwKGnvL1frXwUZMGRLl
         arPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAV2WJHPnfBiEboviXK5//4WsEFZBmkJFy/MJAUtKBZu/eR5LGhB
	MwIcf6sgCbK8dDPEnxxKcvUb9Aj9ZSYO4SMYXoit2LHC3fddQr2eB5y/CUmfMgLgmBFKGjNyvJD
	q8AC7GMEeSLdbpFNz7iu09CnqH7WuoYsSpK2XjvchXZ0F80XdYXMyy0hcTgzS0BZWgQ==
X-Received: by 2002:a1c:67c4:: with SMTP id b187mr2757788wmc.148.1556186390458;
        Thu, 25 Apr 2019 02:59:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMAB9JX1y98M5c9ObK0pFWBLmWNfbtMh5csZ6VU10y01WI/vbAJARLb8bmlDu2UjSU8UZD
X-Received: by 2002:a1c:67c4:: with SMTP id b187mr2757726wmc.148.1556186389308;
        Thu, 25 Apr 2019 02:59:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186389; cv=none;
        d=google.com; s=arc-20160816;
        b=xUUNw3neFUmwIqWo2Y/t3aX4dTSkiZfM0DBN7HmWdfoLst1bPBk+4CnYi3+Lj0U2/m
         HV7oiwtoUsqyhVF27aj/chJ23niexz6tCNVeaC1hlwKy23cQ+xO3xC3ynV4yqZtTjovR
         m8jhTedTCTk8l2kYIfbx2dDEYGOzy8queoXA6wNeyE47DDyJsKJyImaXpydlNHKl8dUf
         +pvDKW2FG/YPPM3mThDuAmd/oiangyAigMg2cuvoxCFPgU6NiiZS8xPndhG4WglDmkSZ
         F3hrIe4RKDgMMhclkzSrm/xCFxQxDGKR4xCtZQWFFC439WShtLJCMXVIgww39aIFl9UI
         nTDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=dtwsC8n4B8GouCY2f1douEN0y/UMZvMUJmpbBiyuz7o=;
        b=sXpXJQB68LZXxnlYcGhlNBrsT5GVibFgnCJRup4chegmwktNCUi7QSr6y6vDlQbj/n
         KhYmcuhsrJk+BvdBTGNqamnNtlWXYkRKsF9lpILfXjw9qFgKoAlbaJY1w9kmMrKFkkzY
         xv9A8Wlx3q92aRBCbWiFbOnI4Ey3s7Nr7LzqLlMAmjV1mBZVz3TyFqqQ/FjvR3oLwMf0
         aeIm/MDzgwBkKNyFC6GPRt2UwoucRQ9Mx6GFN82kbyoPJlGouLtKScmsZ5H/uXlqW3sR
         eO1WcY2rSRRgVC2IXR+XDiPG1sP98GyPc+Nma+jrw0HrW0v+BgRtBqnrM981jppffRJU
         C+Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d15si7113304wrv.294.2019.04.25.02.59.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbAN-000201-Iv; Thu, 25 Apr 2019 11:59:44 +0200
Message-Id: <20190425094803.617937448@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:20 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Alexander Potapenko <glider@google.com>,
 Steven Rostedt <rostedt@goodmis.org>,
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
Subject: [patch V3 27/29] lib/stackdepot: Remove obsolete functions
References: <20190425094453.875139013@linutronix.de>
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
@@ -216,14 +216,6 @@ unsigned int stack_depot_fetch(depot_sta
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
@@ -318,15 +310,3 @@ depot_stack_handle_t stack_depot_save(un
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


