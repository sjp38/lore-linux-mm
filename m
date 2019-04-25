Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E40D0C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB71E21909
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:59:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB71E21909
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 265996B0007; Thu, 25 Apr 2019 05:59:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1979C6B0008; Thu, 25 Apr 2019 05:59:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 018586B000C; Thu, 25 Apr 2019 05:59:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9611A6B0007
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:59:17 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id s18so233242wmj.1
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:59:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=p1GV5L4kXkwF513RFzbpeqJMhNCAHm0+rLW65qR5s04=;
        b=J1PGYdk14PXO244nnMBHMDoFDH3AmpD9+LKxFmcIVxBLHUrEzi5RxNe0cVQROzRo3j
         RuY/wFR+azObBeojbaDfHpGOhFKchy0wwtN7i/K5NtNE18BdyFGMtxQKDqcoZuq9X9DK
         W+A5hpg2V9jTfF1i9qo6WJM1m3GxVcPfvMcaF2vQyUV0mq83LhXNW1QQFEfGgSmQpJ80
         eX+tHNYxZP+8yTdBJVdL9pgLZOvYrCg3EcMZXXlA9NSAdPysSRoi3bdznrsqctb9aXnE
         D8GzmXQA42yJs9itrU57z3/LXyoUaQ8Gs0d/0zN4fXzujeid/Lld2jy/rx+0KVx+8rKo
         uoqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVISk0LSQdWCL/Pf6PRGs0AWS8PB1+dLWyPirAss4Mpa/8F1/bp
	Ne65QJkp2724vDAiaoe/2qFx39jN4QO31IwPMpmSyEzbeg3nldvDMytqqI6D2enIGzvb0TeKi2e
	sXmVhpDTWc4ncopY75affYDvcbJTZ4RQhr1CQvboBurD7rNct5JXV49xpBuUYaz+/Ug==
X-Received: by 2002:a1c:a184:: with SMTP id k126mr2794429wme.71.1556186357085;
        Thu, 25 Apr 2019 02:59:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyd15NonHsPxtknua9o3BcuwW3ZyG02YPtW03aHY8Xa60wxPt/6Jxzp+Tw2tUXaQ1pKb5TC
X-Received: by 2002:a1c:a184:: with SMTP id k126mr2794365wme.71.1556186355981;
        Thu, 25 Apr 2019 02:59:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556186355; cv=none;
        d=google.com; s=arc-20160816;
        b=kN1Bw49tCpxjEI7q1Fx4wVYFjXofY4QWX0m0PlUfBlpm70MH4+zUeVPll2K6V0jA8F
         1SJEI4UKVN1J82lJX/NurlItBL90q/fJAR38bJgQb13ib05HbHnrv5uSz2glefTBzlLJ
         RTJBDqVlJoQagezErcoIZ0mT2r9AFm4hPdBAJS13ik6k5I4DRbAg/NboYwABZLA0Bg3Z
         9fDLaifZKSLwCu2R4DX3iMKxOmb/qOF0mWPjsYxeNHysuaj8Qg8XIVvCtU1wSlB1IASY
         6uwrkqNbEmL1A7LMRllrIzsz+V5MhsNR5+G5SjxkJL8WRIADN7LVNWWV5namaBCE03t6
         rrBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=p1GV5L4kXkwF513RFzbpeqJMhNCAHm0+rLW65qR5s04=;
        b=COLKkSUGr2jGP1A03NLHrDGwn+X3uaB0BMCs4ccwNYhyRKPwAliSYemKmuaLiWAyJa
         JNhBNncASQpxEVnGLIpLfxIoiG8XWCfiZqfkseEyI1QdD365VMNiXd87D40NWPcKIKDW
         i2dR1AvHj1robPn65QxdlhnL1aCH0+SmpExjGVREiUevOqw4SZ03uwBPD7ZMTXvqbIL5
         YLxkM7gRHJ3mEIRKQxkr0n1bjQerkWkWvPYSVyiACffzG9B0aC4SbMjbhHWxy4n66Sdc
         eC7C4WolgkN6aNVtY10TLIPe6xg++E3gLz/WFC9Q/TFEW8hECdggVjcZDqw7VgUIdYZM
         TCIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y12si13912334wrh.351.2019.04.25.02.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 02:59:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJb9o-0001qh-0J; Thu, 25 Apr 2019 11:59:08 +0200
Message-Id: <20190425094801.501919093@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 25 Apr 2019 11:44:57 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
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
 Rodrigo Vivi <rodrigo.vivi@intel.com>,
 Tom Zanussi <tom.zanussi@linux.intel.com>, Miroslav Benes <mbenes@suse.cz>,
 linux-arch@vger.kernel.org
Subject: [patch V3 04/29] backtrace-test: Simplify stack trace handling
References: <20190425094453.875139013@linutronix.de>
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
---
 kernel/backtracetest.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

--- a/kernel/backtracetest.c
+++ b/kernel/backtracetest.c
@@ -48,19 +48,14 @@ static void backtrace_test_irq(void)
 #ifdef CONFIG_STACKTRACE
 static void backtrace_test_saved(void)
 {
-	struct stack_trace trace;
 	unsigned long entries[8];
+	unsigned int nr_entries;
 
 	pr_info("Testing a saved backtrace.\n");
 	pr_info("The following trace is a kernel self test and not a bug!\n");
 
-	trace.nr_entries = 0;
-	trace.max_entries = ARRAY_SIZE(entries);
-	trace.entries = entries;
-	trace.skip = 0;
-
-	save_stack_trace(&trace);
-	print_stack_trace(&trace, 0);
+	nr_entries = stack_trace_save(entries, ARRAY_SIZE(entries), 0);
+	stack_trace_print(entries, nr_entries, 0);
 }
 #else
 static void backtrace_test_saved(void)


