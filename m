Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BB29C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:06:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BC5F218D2
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:06:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BC5F218D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA81F6B027F; Wed, 10 Apr 2019 07:06:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A30E36B0280; Wed, 10 Apr 2019 07:06:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 924F06B0281; Wed, 10 Apr 2019 07:06:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 55CCF6B027F
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:06:03 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id e14so1182150wrt.18
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:06:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=1U2G8OZpL9WLxLD/CbZynvM0j6qReqT7BO3rwF09hao=;
        b=DxMmhPiilF0MI/ocFLBJXuplJCUKeQ8IS1VOKzDkzA2Ah7gxMJpKvkX8fRx8bWgCuY
         WAlwNxo9UxrSBOdqPAEwRaCRzJYrXuvgwLR1dvDxg/LTy5xZYMRUWvrk2S6sh+Zbf9VZ
         zWKFsaOITRSraWvL8mnB+GoJJTpA3rEjRhE3hFDP7M8x+5eOky2UT1qDzDkeGPIfAJrU
         xkEFUvVkBdTGHA5cBXoEWmoXH93i5j0uTBvA0JNDEg4z/Hxij0hboSV1A4CPgbCcxaGq
         P8zodsLLxi8aT3dSaSTdMm9nkLF/UZK87o9uX1m05eVHubTRRpD/LLIQVq47yRrKzlPe
         Mlmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXxasiNuWLtFFiLTzGCCeVYj/5LhvqQ6rzO3bm/18X3MqC4t/qW
	f2jvJ9xnaWb5GaThFCqbkOg8dYe9EEei1e1qXNVwsAlA4lrlqYbusyV6F7Nl5L4IdSK6k2Q2gim
	P4kXzAttDqMPUVeuCaN5pkgWP3CFSABNmTg0TRCRgTqjV08qZa/5KHCTs4Gsh1NDq+A==
X-Received: by 2002:adf:b612:: with SMTP id f18mr15572372wre.236.1554894362849;
        Wed, 10 Apr 2019 04:06:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGPgSXiaIot/FOudZ6VLsf/ef3XUkbfUavQKhDBOTBnJdYXieRJ9QRF3s1GhKSuPa/2hit
X-Received: by 2002:adf:b612:: with SMTP id f18mr15572323wre.236.1554894362103;
        Wed, 10 Apr 2019 04:06:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554894362; cv=none;
        d=google.com; s=arc-20160816;
        b=FWF/ro18sYZ+Hq0kPrHAvqfumv0niwFfG79JGz4fdi2HLk/u6CDVf9hk27P+f6ic8+
         C7KjjzxVKFfhrsBxuh0GrqKmKmywxJqgApmZt3GNG6x26/u6GbLMOoSw3V1CpWHd0LfY
         GK4sR/np3EnX0SavLyPMlalqytEHH+D6NtUCm0J2xZ6evcxzpl93uP0ODO/hbn3Q2F2X
         VnrNGErIBHwx4Pp0RbI18qfCQmS+RH/n92MR08JhKq1n7yVqlJ6cR/C9zz3dpAZJO7w0
         hX2lIAkvUPLOjnJ6F5ixHIapXVhf7AI0xzHjP1m7IsIq1TeT9ClqZFG9gSD/GdCCPitO
         fb3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=1U2G8OZpL9WLxLD/CbZynvM0j6qReqT7BO3rwF09hao=;
        b=oMCvgmh6rtfTQkytr5/uog1JvreA7QurpVIl1daDidNhe1bgT71bCq52DJa44TKIYw
         NpBC+i69SiPKzcK9cJbfP3LBYl1Ql/AAdcYYHMhgW1rPLGH9XB6hm1mY1NgBgQmt3Bx2
         3gFeln7pK025qDGbN2zPMjeii1NGPogilBJ9lSySeqTni/pr2pU8nvU4dRrfEU+uACt2
         jOS4jqzrTvhiQ5dzx7OjwIFb+RjfmYLiESO7koxXFFdLMHYI7weXs+aaZ4UZZigtOZmW
         ZJpZpSQhL8o/Be3n/iJ8F8EYUl76pXMDioAdFodgRp3d2+UbVdsnqbTipe8+OcuwvUoL
         hvHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j46si23048130wre.143.2019.04.10.04.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Apr 2019 04:06:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hEB3E-000590-JT; Wed, 10 Apr 2019 13:05:56 +0200
Message-Id: <20190410103645.685114415@linutronix.de>
User-Agent: quilt/0.65
Date: Wed, 10 Apr 2019 12:28:17 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>
Subject: [RFC patch 23/41] mm/slub: Simplify stack trace retrieval
References: <20190410102754.387743324@linutronix.de>
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
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

--- a/mm/slub.c
+++ b/mm/slub.c
@@ -552,18 +552,14 @@ static void set_track(struct kmem_cache
 
 	if (addr) {
 #ifdef CONFIG_STACKTRACE
-		struct stack_trace trace;
+		unsigned int nent;
 
-		trace.nr_entries = 0;
-		trace.max_entries = TRACK_ADDRS_COUNT;
-		trace.entries = p->addrs;
-		trace.skip = 3;
 		metadata_access_enable();
-		save_stack_trace(&trace);
+		nent = stack_trace_save(p->addrs, TRACK_ADDRS_COUNT, 3);
 		metadata_access_disable();
 
-		if (trace.nr_entries < TRACK_ADDRS_COUNT)
-			p->addrs[trace.nr_entries] = 0;
+		if (nent < TRACK_ADDRS_COUNT)
+			p->addrs[nent] = 0;
 #endif
 		p->addr = addr;
 		p->cpu = smp_processor_id();


