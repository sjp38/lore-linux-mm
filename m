Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61A3DC282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 273292190B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 273292190B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65EF96B0269; Thu, 25 Apr 2019 05:59:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56D6B6B026B; Thu, 25 Apr 2019 05:59:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 344D66B026C; Thu, 25 Apr 2019 05:59:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D83CC6B0269
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:24 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id r7so10963586wrc.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=BUnZ/ks7/6dECieHXMrPx4NPCWL205Gf+OSamdw8cq0=;
        b=A1rpuNG/uyb02nGT6zbPvWZH4G9tsM/3fkuQPAkp8EvSFTPtu09qX3NWao3K9LTNI7
         9J3fmeVPtQRshtQQP3ZC6VM8WyONt+vB9AKCvDfWT+7DmNpFP2nqOBC1YuUNfhzjyVwu
         TQAeJQzyYgmdH+x+zySzKjmSFLALfmmSIRuk6SqD//101eaf4jar5FVcz55kIjwqgsou
         ZyIz0Y83naRo+65K8w0PriGFZGvGxk0HqZK2g09+GpcfkImw5+TtWQGbKOUr74LyMXcU
         8iT7S5+sv/TIT5PeETdp/Kxkp1x2ZtzBLDqQOsIFZEkf3X2mkteTsuVYUzumRyah2vAi
         kZsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXFhgArCKLd+UX41CiT2ulFYNKSxfjqc/9tdSgph4xTWji0VmzW
	sYUwfbK98qs+W0Q+9eCj9dNR3in860GwTEFJRtYrhfH1MN01F2TgRFCXIM0sMtoiKfPSwOWTjo8
	KUxLFpiMcZXnxI8Lkm2cfYeTK89he6q2nC59q4K6SsRY3p70GDtvvEJULxr8yq2ZNRw==
X-Received: by 2002:a5d:56c6:: with SMTP id m6mr24251646wrw.211.1556186364442;
        Thu, 25 Apr 2019 02:59:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDkhAJ0MuEQPmxvi1qhm0TA0ZwuYzXI4QatFOhHFmrJgFOSyn7WtHRH63cGc/vGzEE0eAH
X-Received: by 2002:a5d:56c6:: with SMTP id m6mr24251590wrw.211.1556186363413;
        Thu, 25 Apr 2019 02:59:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186363; cv=none;
        d=google.com; s=arc-20160816;
        b=lXvjvlJWjwIxibiJ4cmW4/GJ4xT50MuL8A3c4z0btj4WIssncwBPjQpviri6INOnN+
         C+40IFQ1fyNyEISHx+mDGWgL/j3ZhovPx6JcdB+K7jClkDgJmUWMIyLeaIFIAdsgaLgq
         +L7NAOG/tl/c6jD8qArVl3Gx90yrjupSYXiA4/hOfUpuDm40DY98Zi/BfAQyINWGqDXt
         4XmIbzSe5A9q3kkekfXk7FGBSNC32ptbAW01cOwiq1vOty9sWMWZN0uZXuUlBaF7ggZ7
         mPcYrXsv3XmzkMevQyoFl1zTvMTLd0s4+IDJxj8+oE13JftSS0Z511tO9zD3w2FIebkr
         typA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=BUnZ/ks7/6dECieHXMrPx4NPCWL205Gf+OSamdw8cq0=;
        b=Orzxc7MyZ8t1gVdLHnShpwqsxEPjeFAoFdZrPrUAMrgR+S65nJXD9FAeJph5Kv1oLv
         9Oj654aHLjz4yVxIb2PLMdm6BMQnTaXmK32N6zYRGY2JZBrVPAQwZSJwMg/T+vCBcDjh
         JyNACUZgh1IKA5l0VqEpwcqssXdbOvjZUpwf+R2wf8BGlVw0bwyzwdkVGaErsR17C00X
         BQ7I9U1S4AAcoAuylZCE9F0srbG1IjWbPaLfT5Hwk4ogfW/zR8crV1nt6HQKbzSXl93J
         4tAeKz4vOdh+Coje8SrhMC8jrjNshJoaCYvzRgad7UuiEpLLGpkDQYxmUpdaFPJjEQzL
         In9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f11si15094986wme.107.2019.04.25.02.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9x-0001s1-P6; Thu, 25 Apr 2019 11:59:17 +0200
Message-Id: <20190425094802.158306076@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:04 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Akinobu Mita <akinobu.mita@gmail.com>,
 Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 linux-mm@kvack.org, David Rientjes <rientjes@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dmitry Vyukov <dvyukov@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Christoph Hellwig <hch@lst.de>,
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
Subject: [patch V3 11/29] fault-inject: Simplify stacktrace retrieval
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
Cc: Akinobu Mita <akinobu.mita@gmail.com>
---
 lib/fault-inject.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

--- a/lib/fault-inject.c
+++ b/lib/fault-inject.c
@@ -65,22 +65,16 @@ static bool fail_task(struct fault_attr
 
 static bool fail_stacktrace(struct fault_attr *attr)
 {
-	struct stack_trace trace;
 	int depth = attr->stacktrace_depth;
 	unsigned long entries[MAX_STACK_TRACE_DEPTH];
-	int n;
+	int n, nr_entries;
 	bool found = (attr->require_start == 0 && attr->require_end == ULONG_MAX);
 
 	if (depth == 0)
 		return found;
 
-	trace.nr_entries = 0;
-	trace.entries = entries;
-	trace.max_entries = depth;
-	trace.skip = 1;
-
-	save_stack_trace(&trace);
-	for (n = 0; n < trace.nr_entries; n++) {
+	nr_entries = stack_trace_save(entries, depth, 1);
+	for (n = 0; n < nr_entries; n++) {
 		if (attr->reject_start <= entries[n] &&
 			       entries[n] < attr->reject_end)
 			return false;


