Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EBF5C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1381206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1381206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 656726B0273; Thu, 25 Apr 2019 05:59:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DB186B0274; Thu, 25 Apr 2019 05:59:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CC3C6B0275; Thu, 25 Apr 2019 05:59:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id F214A6B0273
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:38 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id u6so5302112wml.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=RsuC700IyFocvKBWm+t5JYl3HGqgBnb9GUExX2P7h50=;
        b=QKwc2jjmoMkikQ8TV00wkKsyyRMK7+iwKK4p/Hxw5KxGkH+ruYKNojh3JknoKBkVxb
         30ZHu7Rti0DruNJpghIL6x+x5S6BXQ5hM4ztcFtF+DnjI+eBjRXwbv2NvnnDPYh2r4/+
         8sSwaiMGGEXa+oxi+960YKOhlKFx2SqkOjWRGJ7uWvTajtsFJP2xrfl8ItU4/0d8hsjC
         E5H5652DLv8c6pBUJ12wF+24vhiff+d//6snj8NmoxOjykAFy9K98LMlNdRYxjo3qJhx
         +ZRxVxrOSsmREsVbJ8nWqLg9bJMoWaJ0TVWhAIaFvtMifHA0BQzKuujMuA55AgqbRtcj
         6GEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVe1TwZIvKkiO1OVLzw6khx1ggyFEpQnQrtTIA6HyOp+cpcyoYY
	ppjIB5cHSxDwgvyvkczBFFz6ikD2xre4PBtgmXLk05Ull8PKcYNzBlCQ2R2a4MiDCz1Ycwug5LI
	ubT7/58bQv6l8Y35VW1PSkzM7SryvGSLPqGojfzykY1m8rcJ5ml2dBHOQpi2jcmmj9g==
X-Received: by 2002:adf:dbce:: with SMTP id e14mr24745711wrj.249.1556186378529;
        Thu, 25 Apr 2019 02:59:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2YuNmmrQwXeR4UKtzm84x8sQ45gO6qQi6Ki/a0T2TEcsH+Ed1dhMoTGvsl/bpr1pE5Es6
X-Received: by 2002:adf:dbce:: with SMTP id e14mr24745649wrj.249.1556186377434;
        Thu, 25 Apr 2019 02:59:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186377; cv=none;
        d=google.com; s=arc-20160816;
        b=UEEMPvseGF3oqU+BlpT3nmjq7R1Kbl53vBbG0b7uDxk/YMiiM6rdGsnOFcpr31S8sG
         6oEyyu2DlIVjPBkYt1k0Y9lOJJ/qdDuM1EsB2KKbDd6ULKKtr04iz85371egj65UyAn/
         FZiFdrq5g3s5c7VtiGqiTs3uraaN/Tm6LimFhPLhlxpZxTxrkndRLtViN7UrSEkJCrkw
         ZI8ew4GGnovt45dM6ZfFHQ8rdnA6Vvq0gHXTn31BXpAIia0UXQOEwie0f2ZpITXEpy/d
         rlH07ECYQwOKUfV0f4s3JqgIJc3MXza9d0AlTeW+vQPEX4YIzyt6yQssSS2XYPQMo766
         nVIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=RsuC700IyFocvKBWm+t5JYl3HGqgBnb9GUExX2P7h50=;
        b=bQ/wNFg82Qw3EK3cPR5O2X+RenXja/rvheDDPMUcFt/RKavcaqX5L+sGGzna7+hRDl
         8vCvkmwymM+eemxY25siI9IVMvu3Xy/30iP6bHkAa8h4+DJFcdj7AUPtItOZc4DdczTt
         N3NnS0sZmD0Jjs1JtXvmh/P2vEIiYG5hMu0cDhiq6BaldveqR0T+N0B7BGTx/0oDrE9Y
         /Nrl1sHxtfj4LzUxvQJFHOe722038HLAxTHbujrxKDHLZNFrovlIZIxtrCD5nNuRSgET
         cGCyMAC3A7iksYrbEHRvh50QDtecHktAFTKckzU/HHcq1higUXTMRDeS7DDfkl2m/Xam
         97RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 88si15749706wra.283.2019.04.25.02.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbAB-0001vz-NK; Thu, 25 Apr 2019 11:59:32 +0200
Message-Id: <20190425094802.979089273@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:13 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>,
 Tom Zanussi <tom.zanussi@linux.intel.com>,
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
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 Daniel Vetter <daniel@ffwll.ch>, intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, Miroslav Benes <mbenes@suse.cz>,
 linux-arch@vger.kernel.org
Subject: [patch V3 20/29] tracing: Simplify stacktrace retrieval in histograms
References: <20190425094453.875139013@linutronix.de>
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
Tested-by: Tom Zanussi <tom.zanussi@linux.intel.com>
Reviewed-by: Tom Zanussi <tom.zanussi@linux.intel.com>
Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
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


