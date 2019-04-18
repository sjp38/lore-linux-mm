Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16571C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4ED121872
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4ED121872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1D5A6B0270; Thu, 18 Apr 2019 05:06:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA8C86B026F; Thu, 18 Apr 2019 05:06:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D73036B0270; Thu, 18 Apr 2019 05:06:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBF76B026D
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:21 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id q16so1500602wrr.22
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=vo4FaxAT2/1G624q3L+4nrU71S7g/ECh1ZFuY5z36RE=;
        b=rAuNipPvWzrzA46odsFFI5umCGktXmXro52fFxof4OyEy5Vzl7Ar5tGPHUS/GvmAXp
         PnXQjXyO6iAt0C21awu3FmxI0DpJMyNq3kymwUJJ8JGMELkZ+FfPCp2hO6EjQP4pMPqx
         WcWIOXybrpRYGMEJsyYRcuYAEt86uK4PgX3gF2RGVJ0XwSSn4ZTf89o5wQKU+WvTeKzG
         +WEgZ5I+yJgtofc9N8SpZswmKtTjOMb3XIcAeQB7Xq7KQWxYrBj3Msj4OTRiLRjV3oNt
         oiKZjjFvQmj8YXlVHf+afNeUka0dMsIeOT2ud1iluGIowlhZbG16foWFlK6AS5bu1WOX
         X+wQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVZZRQkxhDBRRo1uCtE9V/XSrVq3titYKDmpQDa3ir6xMDFYAZm
	2zxtjuaKEYj9nQiSMIYPNxYN1fCfzh8vOYiwXf4/8usGN6PLbSDDRZYEfTVv7V7YjNh3DrAY48y
	5jNM8xjDjWXH/Ul6NLqpnSck0FBzTTUI6L4egc2Di3uz1ZV9/nj/w6H5WZmtn7RPDNA==
X-Received: by 2002:a1c:7dd7:: with SMTP id y206mr2216067wmc.81.1555578381046;
        Thu, 18 Apr 2019 02:06:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwF+pQ1JF0wQSom4Hs6R8InEQu+xlG97/3RLIAarF7SRJZpyUnNBer/t2gzRb172atcFMpQ
X-Received: by 2002:a1c:7dd7:: with SMTP id y206mr2215983wmc.81.1555578379995;
        Thu, 18 Apr 2019 02:06:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578379; cv=none;
        d=google.com; s=arc-20160816;
        b=f7hHESS9qBYBzh8IItm5pBQOJSJwwtTF5JowMUJhts8YNKGBO2ss+MWEitfcHXN5u/
         zR/rbiW2rZhsxvxpK3zsVEqPic9PTIGo8KCYtIFrL4dY3KkTyuXfoPHOArxQCasjwWA1
         vfVOgKAp5cHGODBlEBSWV4q8V8hKVnV3fqPq17AyIwVbrnvUznd9sZUe3TjQOIUYi/lh
         T9JgIwzDnp52RMi7+8iA/IKz1uhVGAVpQHtNix/UzgWn62VbhC7tFgmHFe95R12o2gCa
         7n77yvx2ghcEpCcd1UJa6ofBSTb2J4LWfPAqOHzOE3Qv9NT/AP2V1uuGdE5aR6DZ2bdo
         zfWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=vo4FaxAT2/1G624q3L+4nrU71S7g/ECh1ZFuY5z36RE=;
        b=Tz/fpPBu+BzJMkr6U60ixmFraOjQepWRC5SC+FLS3L0tPMI4qs/Rw6oDyOjjzYGSsd
         IuNchivZkuRnydkyV0hHr9qz9YanVh9LzmB+x6pcuitpunPH/bkb0aArClnO8hXiA6ED
         KxCC/5/xdmtzwwopaxe7hu+Rpj+sUN8JhojjgCpVq0LUtF53iI4JinCUwCpxtF/cW2/4
         VWqiO6754+xoU3UTCaTuBoWgug/RzUHwKUceRN5mH8tJbiTAg/Ah4XLJS+nSk0nw2G06
         3/CAEU2h3WuJnv9DoXTf2lj+qVVKwyh+obtB2ebHn3lkbyKbbbLA50j2XhFJ4E3c5X2h
         3G8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u10si1222365wrq.57.2019.04.18.02.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zp-0001nn-CA; Thu, 18 Apr 2019 11:06:17 +0200
Message-Id: <20190418084253.903603121@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:28 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Christoph Lameter <cl@linux.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
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
Subject: [patch V2 09/29] mm/kasan: Simplify stacktrace handling
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the indirection through struct stack_trace by using the storage
array based interfaces.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
---
 mm/kasan/common.c |   30 ++++++++++++------------------
 mm/kasan/report.c |    7 ++++---
 2 files changed, 16 insertions(+), 21 deletions(-)

--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -48,34 +48,28 @@ static inline int in_irqentry_text(unsig
 		 ptr < (unsigned long)&__softirqentry_text_end);
 }
 
-static inline void filter_irq_stacks(struct stack_trace *trace)
+static inline unsigned int filter_irq_stacks(unsigned long *entries,
+					     unsigned int nr_entries)
 {
-	int i;
+	unsigned int i;
 
-	if (!trace->nr_entries)
-		return;
-	for (i = 0; i < trace->nr_entries; i++)
-		if (in_irqentry_text(trace->entries[i])) {
+	for (i = 0; i < nr_entries; i++) {
+		if (in_irqentry_text(entries[i])) {
 			/* Include the irqentry function into the stack. */
-			trace->nr_entries = i + 1;
-			break;
+			return i + 1;
 		}
+	}
+	return nr_entries;
 }
 
 static inline depot_stack_handle_t save_stack(gfp_t flags)
 {
 	unsigned long entries[KASAN_STACK_DEPTH];
-	struct stack_trace trace = {
-		.nr_entries = 0,
-		.entries = entries,
-		.max_entries = KASAN_STACK_DEPTH,
-		.skip = 0
-	};
+	unsigned int nr_entries;
 
-	save_stack_trace(&trace);
-	filter_irq_stacks(&trace);
-
-	return depot_save_stack(&trace, flags);
+	nr_entries = stack_trace_save(entries, ARRAY_SIZE(entries), 0);
+	nr_entries = filter_irq_stacks(entries, nr_entries);
+	return stack_depot_save(entries, nr_entries, flags);
 }
 
 static inline void set_track(struct kasan_track *track, gfp_t flags)
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -100,10 +100,11 @@ static void print_track(struct kasan_tra
 {
 	pr_err("%s by task %u:\n", prefix, track->pid);
 	if (track->stack) {
-		struct stack_trace trace;
+		unsigned long *entries;
+		unsigned int nr_entries;
 
-		depot_fetch_stack(track->stack, &trace);
-		print_stack_trace(&trace, 0);
+		nr_entries = stack_depot_fetch(track->stack, &entries);
+		stack_trace_print(entries, nr_entries, 0);
 	} else {
 		pr_err("(stack is not available)\n");
 	}


