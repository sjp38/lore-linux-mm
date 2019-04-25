Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BFA2C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB918218B0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB918218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BB4A6B0006; Thu, 25 Apr 2019 05:59:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3699A6B0007; Thu, 25 Apr 2019 05:59:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27EB16B0008; Thu, 25 Apr 2019 05:59:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF79A6B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:16 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b3so3791672wro.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=Pgnot/JY/GhCv5DRtMhbab03iCecPXTf4pubBhqngy0=;
        b=TzyLiujkpsIZUrR/IM6a9TFKSK1+8K8qIowvrEcjgnbvbOQoRLvbcwSlnn+MlGpAEj
         0IECrq+ueRE/Zq+0TpTPqUHSTspbq4/RnA3J7zNbFZn2Qi3MoCHpM+h6E5LL9RUbIkb8
         WB50F1bZPRIWb1vMbTQXiw5mLVh6FBhKgw8MCcftlCmEHF25MLPhGvq+l3PUGAToM785
         fhl9GAimJIYocunHmioUwR141MvilWPlo5bCzvinBwVXrfl3mRA1DWRbGi6/+M2c5IAX
         hVDpf1aJRuPLzeEhm8Ye87ppI8f4eX2+QQ+ef0qjnrgwxlAgrTjPnWC6aeUUv29+C7u5
         0ArQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVqhyEThyFn9XBsqJqZ7/rhuQhvPB9j1w8xio6F/+qD1KTA5P+J
	ByfeNyPAaW87HsULktNdFXUI8Ayyse1N1/QuuSfTFFqFzBjBOi5AxiCCJU8IWQUqwQFBfqinlng
	HOfHfiehhcnDQnsZwRPF3DnOamL1aZdZyhcro9gE23FegsfWaudIQyzbzPxYYqq5TPw==
X-Received: by 2002:a5d:530e:: with SMTP id e14mr25084599wrv.18.1556186356283;
        Thu, 25 Apr 2019 02:59:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvGy3urh+0EJy6CdNjvWRyKS/KLimgkISyvIaHdMqQyEMsPAX7mREP+ER3nd8JPsbgoRE/
X-Received: by 2002:a5d:530e:: with SMTP id e14mr25084528wrv.18.1556186355011;
        Thu, 25 Apr 2019 02:59:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186355; cv=none;
        d=google.com; s=arc-20160816;
        b=u7ljINjzYPUmbQAzMROV/YAWJDvnyD5CbBlEeYYfxy3hJelYSZRsa3I2mfZWQA7cTo
         a7BU7qa2vjAPJGHh1xZfmYKafvSaxw0rX0m6nwxaYa4klH7O/lew3TypPu99TgV3B7cM
         +yckfhMf3mIFIM9ztN5576VtPgB5CIV6lfUj5nTxjmcCkLRnM9zZRPGUHEhIEV0cYf/E
         PTQYlgObXem1HElYUTf7SR4Bib5/Aq5wpEwqSB8Ue/T4uwcxOe73QMXA0g/Hs7SlXFVq
         CvD9cLFYRYbSQDCFP0zI8/9JwU5XZ1Rjq2XxA6/b+j6iwfHZLiNJ1+0v1Ie/0v40PodP
         Nbag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=Pgnot/JY/GhCv5DRtMhbab03iCecPXTf4pubBhqngy0=;
        b=TEiTEaQkY5z2WGsrvAy7bsRfNugfiP0JXl+jqVeGFSjFeRKcDTZ+/vvWdT+xlh2KXW
         m/akGbaqz/Hdv8CbWekvn5Gq4Ol/rPKfoiPtHgdrYq3aZwiKidDI62iazdSQE3Y5OwSM
         bmn6SnxhfGkA0PQYgY2PyGfvRvgOlref91r2XrCMhFdOaAHMdSc+X6YvWFehKbxlv0Gh
         yFBPKOQxgdoQ+QDMBLOE11tKePd9AbEbV3sK/tNctjxAdbeHjebGxhrwZR/98yhMatL6
         xvDtihcNP7Gs8KxbiQEqy7h/L2bAGgBy49JpZRWUJKA7zl6rcE2YX+wZ/H7CiZ3Q16hD
         TnpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b142si5333007wmd.37.2019.04.25.02.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9r-0001rD-Kz; Thu, 25 Apr 2019 11:59:11 +0200
Message-Id: <20190425094801.771410441@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:45:00 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Christoph Lameter <cl@linux.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
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
Subject: [patch V3 07/29] mm/slub: Simplify stack trace retrieval
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
Acked-by: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
---
 mm/slub.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

--- a/mm/slub.c
+++ b/mm/slub.c
@@ -552,18 +552,14 @@ static void set_track(struct kmem_cache
 
 	if (addr) {
 #ifdef CONFIG_STACKTRACE
-		struct stack_trace trace;
+		unsigned int nr_entries;
 
-		trace.nr_entries = 0;
-		trace.max_entries = TRACK_ADDRS_COUNT;
-		trace.entries = p->addrs;
-		trace.skip = 3;
 		metadata_access_enable();
-		save_stack_trace(&trace);
+		nr_entries = stack_trace_save(p->addrs, TRACK_ADDRS_COUNT, 3);
 		metadata_access_disable();
 
-		if (trace.nr_entries < TRACK_ADDRS_COUNT)
-			p->addrs[trace.nr_entries] = 0;
+		if (nr_entries < TRACK_ADDRS_COUNT)
+			p->addrs[nr_entries] = 0;
 #endif
 		p->addr = addr;
 		p->cpu = smp_processor_id();


