Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00012C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC40A2183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:07:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC40A2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0FE46B027C; Thu, 18 Apr 2019 05:06:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E7D86B027D; Thu, 18 Apr 2019 05:06:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B2B46B027E; Thu, 18 Apr 2019 05:06:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 357C66B027C
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:46 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id s3so359673wrw.21
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=TmdqglcunI4wOAmrjgXMIH7hh4Tcg955OWTpIeEnbW8=;
        b=jnbDrFGktQkLNaufxdT9DsXopVCch52HNzPMXKnM45LjfcrpUq8Ornh87tQE+Icuef
         zPMd4Wz5J0bcPZlWlIyRW2gomdqVUfOomkjfxm2/q7E83+3tNtkZeUNRM4utUePJcwal
         Yjnl8f0E77ZiD7B7KEinJCRH7fIGYNTFqDWwhzN3cVwGlvoFf3D118oqJAnIFme1V2ic
         iP/t9IuZAx8aAmK8p/yYl+rVisCGZfBiYE2GFZpAjtjY3YnImPOE5LLUcv1LW2arR/A+
         czDt9goLtEyDnFcdjEDyJliqz8+4cDjfqonQhPJP9Oaf2xuhvYQ8gxf3Rkwy7aMGwiBY
         gDjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXrdLKtp5J3DkdaT5Kkr1ZH10ji5aLgfgsy1+2LC0wzZw9dOLZJ
	xAlwJlLRFwYSvNHTD5xOQlbKE8s4TJp9s1KfuDe/RWTETUc9rD30Q6oxcx7/GD1mrcSSWtrTcp4
	if4D0HbW+Yxh7niN4uJpOO4OlKwDpYin2gFB84txbpFRupacISgVjbVR/k6WmUuGMCA==
X-Received: by 2002:adf:d4d0:: with SMTP id w16mr3332968wrk.318.1555578405755;
        Thu, 18 Apr 2019 02:06:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXAoFbZ/Pj4k/ND3vXXt8JztC3VmlAe4wn20efWScTjfE4ae2HgqmNZ1JXCRy+erVzwXXP
X-Received: by 2002:adf:d4d0:: with SMTP id w16mr3332920wrk.318.1555578405022;
        Thu, 18 Apr 2019 02:06:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578405; cv=none;
        d=google.com; s=arc-20160816;
        b=TCou9CLdKDmVYWu7qduz0kqYxnekh/KGM+tfb/a9hSYltTIuB+EwOU6uLow7xytCIj
         LuOFc2x/QbZO66jWibeA1S71LMVzEvnEBb5CkqJDkk0idW1tMXwKHSwcQBvihcN89OCq
         wiqDwh2SH6ebMh4cQEzaUHGWLz7VxkFnKch2V1q9BZYymey9ICwyiNt6QhOvOlrfqMbd
         gPLKQIEsEjdGhdtLYdI/OF+f9OpdHShRr1FR/NAhYeJCMvnfbrBzvAmC8/OSwgFyEcgk
         ceKEpFIogd0xIyBIayPiXVCyMesBiqu3WAHT7HBhFlp3FL907oha5mCIym7/yX6ROyw/
         AOJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=TmdqglcunI4wOAmrjgXMIH7hh4Tcg955OWTpIeEnbW8=;
        b=l+cGtEj/F4Z0UD3yLjmnf/Wyw3QfcRalknWzKoEdwgKatRKwucD8W76kWCMHEu1t+M
         8JtdCB48DsU0Y6LlM0VlTqQrGW5VWmV+8uH3K/oRN2QI97pwLAOJ/fbd3VjUnwn0Q6ye
         W5BVnr5zFRFy6vNLnH/GJIUBuEetnqRYGN+K+6Q2oFPwq4UfRWbkfS7b6T629Xb5yYaU
         EaTNhffo54qlkZTW9t1JGHI2CiA0d9Hr9SsXZ9/dOKyr+DLthYYA9iHi9bgVAQsGBITs
         tgS/PySVkiqI6VCjLG95iiVhsZb1NR2JNjR8xptcT2Y9exWjUxVXIKDj/vPTEY54G1Dz
         yiDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a194si1103363wmd.192.2019.04.18.02.06.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH30D-0001tl-Se; Thu, 18 Apr 2019 11:06:42 +0200
Message-Id: <20190418084254.910579307@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:39 +0200
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
Subject: [patch V2 20/29] tracing: Simplify stacktrace retrieval in histograms
References: <20190418084119.056416939@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The indirection through struct stack_trace is not necessary at all. Use the
storage array based interface.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Rostedt <rostedt@goodmis.org>
---
 kernel/trace/trace_events_hist.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

--- a/kernel/trace/trace_events_hist.c
+++ b/kernel/trace/trace_events_hist.c
@@ -5186,7 +5186,6 @@ static void event_hist_trigger(struct ev
 	u64 var_ref_vals[TRACING_MAP_VARS_MAX];
 	char compound_key[HIST_KEY_SIZE_MAX];
 	struct tracing_map_elt *elt = NULL;
-	struct stack_trace stacktrace;
 	struct hist_field *key_field;
 	u64 field_contents;
 	void *key = NULL;
@@ -5198,14 +5197,9 @@ static void event_hist_trigger(struct ev
 		key_field = hist_data->fields[i];
 
 		if (key_field->flags & HIST_FIELD_FL_STACKTRACE) {
-			stacktrace.max_entries = HIST_STACKTRACE_DEPTH;
-			stacktrace.entries = entries;
-			stacktrace.nr_entries = 0;
-			stacktrace.skip = HIST_STACKTRACE_SKIP;
-
-			memset(stacktrace.entries, 0, HIST_STACKTRACE_SIZE);
-			save_stack_trace(&stacktrace);
-
+			memset(entries, 0, HIST_STACKTRACE_SIZE);
+			stack_trace_save(entries, HIST_STACKTRACE_DEPTH,
+					 HIST_STACKTRACE_SKIP);
 			key = entries;
 		} else {
 			field_contents = key_field->fn(key_field, elt, rbe, rec);


