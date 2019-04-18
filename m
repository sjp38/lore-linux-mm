Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06C8FC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C103C206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 09:06:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C103C206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0F546B026B; Thu, 18 Apr 2019 05:06:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBFB76B026C; Thu, 18 Apr 2019 05:06:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A899B6B026D; Thu, 18 Apr 2019 05:06:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 524216B026C
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:06:18 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id o16so1521652wrp.8
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=0M2OLeqxAULJLF3vLiIc4vZkAtZeGcOr3pXLUexTG5I=;
        b=Ys1+IYRZHI9BG6VkhAyivZElvgDyHEo/yKt7/i+wNje+5d6Xj2W01mVCoxmDZtOHNe
         KQT+yB259Gjr38ZlEAN07TL/jZO3riAbOG0tIXTy/UO4M9/Qwx4+NH4V9pxko52TghKI
         QhaQdVta//5NK0kN6f//k9m6gG8oT1Q8LQGETgz36cmaYm9RH65RYQ1zTo7bzTbs8FwU
         X/Eqo4wKkmGfO8iMbUGc2IwLLbk/vylJeJFW+UELNEAl6NWNuORsf0W1lYAnoVDZEYzp
         JqgNU+Cuih0zAW5jzPWVdIJW9dzHGaDvkKjAZVy9OUlkwraWELSzsQxJixFDBz+/9Hcx
         rdrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWoxBGVpobMSnzKoPFHrE65/lVe5xCJVK2VpilaITPQMC9QXceE
	ehvj1JZoNPvtZjYJVy2FiKHBWJd3MpUXOpVWHTSuzce7OQrrjEb13UK73vuMaL2Rst6TqskWp6s
	z8czB9lHFb6HOBlXo2xmqfSg7qqkwgE+072QBwoDjVjorZKkzlc4j6xjgXO4ptzoXHw==
X-Received: by 2002:a1c:7512:: with SMTP id o18mr2356413wmc.68.1555578377864;
        Thu, 18 Apr 2019 02:06:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTcsNIxWvAbBy58Mdmd+4E54O8PHh3nKmlDoE45DGWMl2iMWvxlfBMyINtj7SMUZ1C/Zl0
X-Received: by 2002:a1c:7512:: with SMTP id o18mr2356326wmc.68.1555578376615;
        Thu, 18 Apr 2019 02:06:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555578376; cv=none;
        d=google.com; s=arc-20160816;
        b=BnXvBYKv0le1HWHDAcE4zzxlXd2fifKVjYS3syQlKLIk8eekADDY8Qf3U1g3hCI2pW
         kc+G/afclRx4mBQVLh/ITReMXauPVFUhDMFAgbrfDae//9PE1B4amLBBuCOj1k1VUcJe
         9SXN7BndhWeRkUKN+KJm4+unxihxVUw2TzkW/zFQaoAppDOjUrvA4IffzJG643UyRGLr
         qtS6oxPK/eBXA9KL/+5YGvVd/7FjxB2O4g02tIUZhzeIL11k/CnSPNgKsCHziN8S3vAN
         CDOWNlr0UsFtZfE/iqQqgaNMpi307bx29WOaYEqOw0rr97+zz0lfih00teQtby2HuI8m
         f59w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=0M2OLeqxAULJLF3vLiIc4vZkAtZeGcOr3pXLUexTG5I=;
        b=Q681mtisgEi12+VKbuwR0rR7VC+jvha1TJbz1TOfLOIjra0oX6HL/1B8alL5dF1yW5
         B4catw9YL6Dx8EdCpudIdSBIPFwsvS5JxDPukq9nMrBhHI740GdbpwAXAO+aFA2YFfaG
         IWEongJfRSUxZXtpwb4xRJIpA98ITrzfwJowXaIWt1KA7ksELIerv7swW78iqkJghcF2
         ZjotziFg0cnDh/vV48I4jJhVkZWUmHOPMmeqFbQ7kdzQR1jGna3hxbnjrDlXbT3oyDk8
         Kqph4QlSuLBeVeQwPJ6JKl1L71KxevWof1zhJcQ+VbHlH2gAVBtjc6M5+rCan5kKbiwR
         avtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a11si1060932wmg.137.2019.04.18.02.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 02:06:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH2zl-0001nA-9k; Thu, 18 Apr 2019 11:06:13 +0200
Message-Id: <20190418084253.720040206@linutronix.de>
User-Agent: quilt/0.65
Date: Thu, 18 Apr 2019 10:41:26 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
 David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>,
 Alexey Dobriyan <adobriyan@gmail.com>,
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
Subject: [patch V2 07/29] mm/slub: Simplify stack trace retrieval
References: <20190418084119.056416939@linutronix.de>
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


