Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 260E9C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAA2E2183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAA2E2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF4A06B0275; Thu, 18 Apr 2019 05:06:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA3656B0276; Thu, 18 Apr 2019 05:06:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA8CA6B0277; Thu, 18 Apr 2019 05:06:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 780BE6B0275
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:38 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id k17so1526702wrq.7
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=dFxGRxA6GS3JHurHOjsZQL/dY8U8+zq9Oil1nNFfiJU=;
        b=aYMwnmg5RKxQKoj09kPVfQMmnQ6uPZBgiT5B+s4Ie/LP/9usYnrsYw1oaDdPsvtL/V
         HycBoGQb4sW5020yDfMCVK5Vl4lzFIVWL1K9MD/ctNYT1yFxiKRh+2bAqfKuQXVCnR07
         uqX+DNuiohBHlaA+RDauhuCjLGfQgreF8mGDDgHw9q6GyEkQSXe8ZSpft3twEDKtU3g5
         +WPaQ3hXwbJBSwkF17Bha4Zqmahchzls9PVSu8GrXpvadQ6oM9UnkHANhWdx/jxvHvqL
         WH/t4h04bOYAY/0Ymjh5518z896gMKXLOxgWDVsJlPc+CDwpBcOVdhYDAI+agKdvVblJ
         mW/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUpRZgBYWBjONfsLq7E4VsZYh+3InfBV+6b8qre4pndvbPXAe7q
	HTzFeY0iU1oAbZOeS+ug08ohTH9kbY70DRQwoKEVA9+u93TmhoQu3AeppE/1LObQZr2kEIfRjCG
	EVqAbmUookXdCeivxGydYH5ewllWNMRyuU9xZdCkMx6DnKhsCMS8Ja8tSzO2E6KD24g==
X-Received: by 2002:a05:600c:211a:: with SMTP id u26mr2388057wml.74.1555578397906;
        Thu, 18 Apr 2019 02:06:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1NM1Dwou4qNHAIJC517SPt53PiQSIWtwyLSL3BGjEkcElN8KPc8M9NmxZsvOINtgErs6j
X-Received: by 2002:a05:600c:211a:: with SMTP id u26mr2387977wml.74.1555578396704;
        Thu, 18 Apr 2019 02:06:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578396; cv=none;
        d=google.com; s=arc-20160816;
        b=qyKGMh/VnHY0FjTpQsqTykwgLnqxqpTDIbqopmZCZ91zXJ76FL6hMPMKTkscrE7ymD
         mUhKeiho3Gsl45KR4IwgcvlQLiRqFejWyWHFPOWjf22c3V80+wEAFw2JbZaEy9L3fvvc
         Lw8u6XvAy8kXGobG2T5g7kr6Ic3TSm8fCcsG5MKAF/UA/ee+51qU1Ntyf0iwROjzTDEH
         eHl1mFzvANLle5Z2Skfsulnn0fx2n1c9hQeSi47KFku6iTADzYgkq2LZxeUHkWHF98mF
         jtP/EepeM/TZ9i8JCqwKlT9wv5NLJma/qwOTc1ygTc4Xv0yauBkef4ZSrAR0V/hjeKMO
         1KJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=dFxGRxA6GS3JHurHOjsZQL/dY8U8+zq9Oil1nNFfiJU=;
        b=pDHcg5XgCQsIL4z5iQfv3U3uyJHHgtjF+2svmQe993RrmQcmRxraJ0DO99yI5htmQc
         Cd1T3SJqKcM/9spRopQ5D4DqZW92bcsDwI87jzZr5GoQGSyr/dBU/Iw242vmt7hZj8KC
         VFIukBxDSCdObvc6CtmasWxbMEN+7WECZoz8VnIbvKkuPHso2svzF+A9whO9uvzLTGWD
         dZ9b5JgpCSrE2APJpq9C/M6q1QlP7zs+bpHe0zuZYBg9V/CmQ0FuCCD9Fw7Pazd2Ztfm
         /LHPlhuXGpdxWVzJKtV7GoxiCUjS9RKCpFIUyB6BX4e6R1zWRHLNw+eiUkcfEmNCHUrh
         OkBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id e8si542369wrw.290.2019.04.18.02.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH300-0001qd-GI; Thu, 18 Apr 2019 11:06:28 +0200
Message-Id: <20190418084254.361284697@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:33 +0200
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
Subject: [patch V2 14/29] dm bufio: Simplify stack trace retrieval
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
Cc: dm-devel@redhat.com
Cc: Mike Snitzer <snitzer@redhat.com>
Cc: Alasdair Kergon <agk@redhat.com>
---
 drivers/md/dm-bufio.c |   15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -150,7 +150,7 @@ struct dm_buffer {
 	void (*end_io)(struct dm_buffer *, blk_status_t);
 #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
 #define MAX_STACK 10
-	struct stack_trace stack_trace;
+	unsigned int stack_len;
 	unsigned long stack_entries[MAX_STACK];
 #endif
 };
@@ -232,11 +232,7 @@ static DEFINE_MUTEX(dm_bufio_clients_loc
 #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
 static void buffer_record_stack(struct dm_buffer *b)
 {
-	b->stack_trace.nr_entries = 0;
-	b->stack_trace.max_entries = MAX_STACK;
-	b->stack_trace.entries = b->stack_entries;
-	b->stack_trace.skip = 2;
-	save_stack_trace(&b->stack_trace);
+	b->stack_len = stack_trace_save(b->stack_entries, MAX_STACK, 2);
 }
 #endif
 
@@ -438,7 +434,7 @@ static struct dm_buffer *alloc_buffer(st
 	adjust_total_allocated(b->data_mode, (long)c->block_size);
 
 #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
-	memset(&b->stack_trace, 0, sizeof(b->stack_trace));
+	b->stack_len = 0;
 #endif
 	return b;
 }
@@ -1520,8 +1516,9 @@ static void drop_buffers(struct dm_bufio
 			DMERR("leaked buffer %llx, hold count %u, list %d",
 			      (unsigned long long)b->block, b->hold_count, i);
 #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
-			print_stack_trace(&b->stack_trace, 1);
-			b->hold_count = 0; /* mark unclaimed to avoid BUG_ON below */
+			stack_trace_print(b->stack_entries, b->stack_len, 1);
+			/* mark unclaimed to avoid BUG_ON below */
+			b->hold_count = 0;
 #endif
 		}
 


