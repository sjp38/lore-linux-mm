Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 890E4C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4698E218D3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4698E218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0373E6B026C; Thu, 25 Apr 2019 05:59:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2C106B026D; Thu, 25 Apr 2019 05:59:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCBF26B026E; Thu, 25 Apr 2019 05:59:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EDA96B026C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:31 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id u6so5301914wml.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=dFxGRxA6GS3JHurHOjsZQL/dY8U8+zq9Oil1nNFfiJU=;
        b=NX5Hn+JSbM+A7qd8XXfrYm7CX1p8FnfLmx7966W7ejHUiYSzn0OPXeqGNoE+ZEzvIj
         R8TiqdL/P8/0xsew14iKU7uz2FjJ8rJDCN8NKilUZqHGmIyEMxhadcNRIS7tP6UxHg7w
         HDVPAUE8PyKIeiB1DQlVYQxuJasfDpGjzpUuzKV85Solsr+BLr+2kCsC8+qw8/iVjuRh
         aQFlkqK8OllAQ4eOToCOTZ8uEie5Inqvbh7Z8TupZtDRMxzOYlgsMf19koFrPymXMXhk
         leZM+NWiMJoVNbtj0DvLGtAVlLacLB9ujvYVCc2YAnS3n/B0Jp9DQ17MMt5iPJO2ZcYJ
         /uQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUXltzJznQkbvNvUuwFwVFQ9zM72/0mt3vnZhUGJIgCsmwKDcG7
	9sQWmDiALQ8/t/rbdAVIUgU29g/g0BCpmfYQXaFnmL9RLKsFBU74HoaoOIK9dbSw1FbiJdbsYDU
	8DpmWsIkHg6JIuJqQP3MdqVqcxVxyxuK3LITweoj83TUphcwL5frjr/ocOOuWzKCYaw==
X-Received: by 2002:a1c:6a0d:: with SMTP id f13mr2785977wmc.76.1556186371090;
        Thu, 25 Apr 2019 02:59:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaaIbT1znNxUk3TXF30NzrWWqcPHxihy90i6jm3tcJF6lbIxS6NMh24+C2zRBfqhgH19qS
X-Received: by 2002:a1c:6a0d:: with SMTP id f13mr2785913wmc.76.1556186369877;
        Thu, 25 Apr 2019 02:59:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186369; cv=none;
        d=google.com; s=arc-20160816;
        b=xH8wnHICp5Unw9MoA4Ryd34QUrPoO+r6W1CHGeqL6/2X1VdvnHOYrqTm2Qv2yen2Yx
         gM+uzBHdOfLQZvPEr6RnaOcmKQZ8vFVMMDDppaeQ3tqCds8J6+mkgNCJVOJGSAcsT8Z6
         IeFUDg7wNRaFeNZ/bT2JYUWiPWzoARAVsYfjGyfaKWYPEdFyCM+UoVoR8BaEmO1A+Cji
         hnKGbx8XtRBGRKl0DkXN33aLji3loHikgKkl08LaArNUN1PEuKv9yUlDIhHoPWqI2c6z
         MuoD9qNrFg4CJ78Chi/fZk/VdcBD/zDjk8DhhJv8ijGsbhAbHur2CECbu4W4EcKNXOkD
         YM5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=dFxGRxA6GS3JHurHOjsZQL/dY8U8+zq9Oil1nNFfiJU=;
        b=jtEut9frT0OBVGCVwLf+hZV2AU+4mTH0IDt92R5Aazm/DDDAF8sXoCl1f0E4gmLMlR
         QTX4pitwAsy0JoTtI39fHx9h2fTpNmifrxTBs7MIxxS3gxAOrONPzdFt/H5KM5CC7b71
         6aM8u2EBlotzq6xng7JYbUwH8vrOSpOXehAw+VEM1IeLhMubgwa5RKiuWGGDAGHBXIGp
         UDoJqEQ554Vfi1usjcwjW0fdXqTn5U9GBUBtvTmJ//+8XST9/ZIgSsDHVPlTxqNPgLlI
         mBCGtSQqI5yq2WzAiqRZhM2MisJpdbq5T2nGmj+jBJx2+o6b62x4Yi1wfjyNO62032ja
         /B3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 6si14765049wmo.109.2019.04.25.02.59.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbA1-0001sk-Us; Thu, 25 Apr 2019 11:59:22 +0200
Message-Id: <20190425094802.446326191@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:07 +0200
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
Subject: [patch V3 14/29] dm bufio: Simplify stack trace retrieval
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
 


