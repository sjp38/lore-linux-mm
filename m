Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D00ADC282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91EC421900
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:00:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91EC421900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 458776B026D; Thu, 25 Apr 2019 05:59:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 408116B026E; Thu, 25 Apr 2019 05:59:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25A0E6B026F; Thu, 25 Apr 2019 05:59:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDAA76B026D
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:32 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id w13so5290802wmc.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=NV6JAa7wwuylvkaEkDT0w0mvqeqkCtkC066wzQ8DD70=;
        b=KNI6uApvMrqoAUUu0FFzppptgUSL0YNOF4ZqIFlQZuRlxp35siX3wh/T+LWx/qfL2Z
         cMpFp7lVcixqEsOmZVdPKvcAXwnWLusEv1Y/w2Z8/C2l/dTv1vC/HtTcW7KPma38TCsl
         NE4hLpGPXKsgUODxHPbPO4eTc6hJiJmIEpu8Z/Hg3aHg/enPkqszz1LdmjmWJQDCb6KF
         CpgOS4yn5XzbrReFjQB/RUwq5A7LtKRtYeqE1miWt1szUJ/+Dtm39TLx6Do2959hteAH
         P09AMxnOLWGlosXXKBFs60k57699DtsdWUiWtLXlWBv3/VPsezMZ+6rC0eJW+jnl0lQe
         Tw4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUvAnz1liFoJnCfCgXG0BOGAKG5tiy3PXlTweuzw7SAH0NU49Z5
	pCgzvWM52KkN396E/+4DCIk+TmtMb6ZcV5OcHOJqpZaiB6+5LtZLHp5JmjxIuT11XM2vTLP8S9M
	+jTdi4wAwiNkLMvWtFYCNPp+zgqm5taPJs1ibdy+8xVstLPOApUksdvO/cdG36ZkIpA==
X-Received: by 2002:adf:b646:: with SMTP id i6mr11765829wre.12.1556186372392;
        Thu, 25 Apr 2019 02:59:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDUl1DNu2xjPVvVtGRNIeRZ2XnIW/QOa5nv/SsUytOUN0nJsaN1LrQo89PpFtpmt95t0fO
X-Received: by 2002:adf:b646:: with SMTP id i6mr11765774wre.12.1556186371384;
        Thu, 25 Apr 2019 02:59:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186371; cv=none;
        d=google.com; s=arc-20160816;
        b=qTKBKiDCZIhVbz+zjv7ruP6qlOiWjOHhdkf3j7eXB9G8W5wSLEi9GYkdrqTpKXI8Kw
         kimiZO8zXOWJymx5muTo8ikkKzLaEdTxTjaVLCPXXYEb3iR8a6wg3ja2oc2KnM5jXXbH
         ktaROIShsNEzWi3H+3RPnkjuRPy8GmnZd/DL7r+huTnTaqeLkmPCoQdP7YQubffCpiXF
         J2IRfDlUUA9osX1UKB0lgticOI3qFHwUCXxOwn87qpwisB42OZ9G5NQob8WyChUnQdnU
         p/Aqp+Eb5E5FslQ8P81vUUvIG7NPQjORpDKcv2SVwLqEyQgue2z8eGIBGSng7tsZpoR9
         skWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=NV6JAa7wwuylvkaEkDT0w0mvqeqkCtkC066wzQ8DD70=;
        b=Awmul4j8PwenMIonI/uX8p6sbLRDhr+y2jmFcMR0uaYPgSHdZqsi5l3cHEwoWsLYAx
         Oh5TIdUcNkvhmy3APsYow9FQ3FhH/qdGaRlv+nar2a5TlVka8DRNipROdECoTV3LTO+T
         o4Ct67akIG+BvBg7iwHclFovv9NPtrn9NLsKv5E3SNieT+5KzNXxHKiWSU1Q2lg5dKdp
         rDoRjV/CYGJBfvpw1vP3k8ny+vnGPzTkIBP3Z5q9YgBOPEJ5Ki/22Wtfru7RsOOi51GE
         JjRRuYMtRISQKClaWk6i46CH2wXKZwcFw0rJ5uLQg8ZEqzd6CUHS8YLz58QWb/QDrrbu
         S8lA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k12si132784wrn.4.2019.04.25.02.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJbA0-0001sR-AQ; Thu, 25 Apr 2019 11:59:20 +0200
Message-Id: <20190425094802.338890064@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:06 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Johannes Thumshirn <jthumshirn@suse.de>,
 David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
 Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
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
 Marek Szyprowski <m.szyprowski@samsung.com>, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 Daniel Vetter <daniel@ffwll.ch>, intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>,
 Tom Zanussi <tom.zanussi@linux.intel.com>, Miroslav Benes <mbenes@suse.cz>,
 linux-arch@vger.kernel.org
Subject: [patch V3 13/29] btrfs: ref-verify: Simplify stack trace retrieval
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
Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>
Acked-by: David Sterba <dsterba@suse.com>
Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <josef@toxicpanda.com>
Cc: linux-btrfs@vger.kernel.org
---
 fs/btrfs/ref-verify.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

--- a/fs/btrfs/ref-verify.c
+++ b/fs/btrfs/ref-verify.c
@@ -205,28 +205,17 @@ static struct root_entry *lookup_root_en
 #ifdef CONFIG_STACKTRACE
 static void __save_stack_trace(struct ref_action *ra)
 {
-	struct stack_trace stack_trace;
-
-	stack_trace.max_entries = MAX_TRACE;
-	stack_trace.nr_entries = 0;
-	stack_trace.entries = ra->trace;
-	stack_trace.skip = 2;
-	save_stack_trace(&stack_trace);
-	ra->trace_len = stack_trace.nr_entries;
+	ra->trace_len = stack_trace_save(ra->trace, MAX_TRACE, 2);
 }
 
 static void __print_stack_trace(struct btrfs_fs_info *fs_info,
 				struct ref_action *ra)
 {
-	struct stack_trace trace;
-
 	if (ra->trace_len == 0) {
 		btrfs_err(fs_info, "  ref-verify: no stacktrace");
 		return;
 	}
-	trace.nr_entries = ra->trace_len;
-	trace.entries = ra->trace;
-	print_stack_trace(&trace, 2);
+	stack_trace_print(ra->trace, ra->trace_len, 2);
 }
 #else
 static void inline __save_stack_trace(struct ref_action *ra)


