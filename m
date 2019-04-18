Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E58BC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECBD8206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECBD8206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AF116B0006; Thu, 18 Apr 2019 05:06:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52F386B0008; Thu, 18 Apr 2019 05:06:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BE756B0006; Thu, 18 Apr 2019 05:06:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2686B000C
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:11 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id u6so1455570wml.3
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=p1GV5L4kXkwF513RFzbpeqJMhNCAHm0+rLW65qR5s04=;
        b=lMnrI0E6WwqjukEHQbuMgutqTapQh1xT6XJI2eV353k6Tlc5t8TlwMd1b0W++oIsMc
         vj1InJCWlDzW5xHjfn0p/lzXxsieK1d7D0+d9n78N5v5XqxAH/zadytL8P1mGh5qDJL4
         rcWdp7JjV+6+7zm9PYOOlcWFPJ9ftmNeObY1sipkHfF4TEWGdC9plHKSMt9Z550BGf0W
         acp5JiUOd2TeCPlLhY9i2/KlIza17UuDiUIAVeCN+XNbFeo/zkiAoMWJU88FxGdsR0kS
         LERm483WIV4bNBS3YjSX8pSjVuE4s2XnJ5bryEDOaRXx6KimW0Eem257nnPBBqtUjdp3
         OAAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWQoMU+u3CIAp3vSYyXCQVUUWbSjS2JCgoU+bUtLgmAbQ9N6wWl
	PqqiOubcdtdpYdfcRAQNedHq4pE1MJH4NCaLWCG7mQDxaqSVdxfu13FMmAmy97ripoS/xaqz7km
	cgVReVtP1ao7l6tX9/6CMN+EgG92uzYz5zYODuj2tACwT5qwRPV3nRvYqAnZwoQbBCQ==
X-Received: by 2002:a1c:1903:: with SMTP id 3mr2182619wmz.103.1555578371138;
        Thu, 18 Apr 2019 02:06:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFXomz58L6bjRWX1EiX8MZ8XiYXNuCfKfuTO9V8Tn5vZBzGgbPtTHcyop3TcMIeUDETlCB
X-Received: by 2002:a1c:1903:: with SMTP id 3mr2182555wmz.103.1555578370190;
        Thu, 18 Apr 2019 02:06:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578370; cv=none;
        d=google.com; s=arc-20160816;
        b=vlOBNWU8Xzs4L+T/ynffsE8nOLqoQfFGKAhkavS7CcGeHl93pub6RyI0mFDMRcFHRp
         78vm8fp8UDaqAc8hpFj0nL6U0LGe0IzRBak2diFNSWOk+ZrXULPb2ORkUvYX/csHNP7p
         dba/6451L/1+x484B+nktdnRGL+QMlXyZpRoSIWOqg0ZOmAn6hJI2kdLxf8knwMkm40o
         CptLLVgyNVdFbLqSE4UgvbVcrqbZ2eGbckLICNZ6sySq6kAY5VvVVahjeJBmzWjVBaMv
         2GfSsitc4cYD2xLy6zd8EZWsCQ1YHJoeI9ZDiwdkBUEoo9aTsfASvhbnSGVXOxJLgryL
         06rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=p1GV5L4kXkwF513RFzbpeqJMhNCAHm0+rLW65qR5s04=;
        b=l7/prIImpCltXC646Y+bBzUSgbCKJP+qPDdK1agks2biZkdUANDArbMgcjr9DVzibN
         F0ySXpdIchWoivo8KTQjy5eim57wOLXZoMB4BIQsHXAE+9FsTNJqcu4za+WjoKnL8hXs
         xyIi81WZ2NJzybke0/sJBctHhJvAfU+sq9+ePoZjks5251Ctejq4ZLs8iEeG/ZpxHY6m
         pEtnLLkgAWJuKd3sO8ZK5lIFGeTNTyeh98rvGQbYlipvKdDegUrw1jEz53IugMUnym1Q
         yQ1ZjXNazoTIUNwNo7QEaiTD99mF/nI7CpEXkl5O4wyn9Wa1PHRvvvT4h8u7c/PRMbQa
         0iCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d3si1228672wru.149.2019.04.18.02.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2ze-0001mB-SZ; Thu, 18 Apr 2019 11:06:07 +0200
Message-Id: <20190418084253.431851214@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:23 +0200
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
Subject: [patch V2 04/29] backtrace-test: Simplify stack trace handling
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


