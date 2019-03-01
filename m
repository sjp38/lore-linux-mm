Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57533C10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 20:41:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07FBC204EC
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 20:41:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07FBC204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83A4B8E0004; Fri,  1 Mar 2019 15:41:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BFD88E0001; Fri,  1 Mar 2019 15:41:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 664198E0004; Fri,  1 Mar 2019 15:41:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 210958E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 15:41:07 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 73so1490089pga.18
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 12:41:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dU0QwGT/3+ioq223MyX/qmthmGilAo6Jq4PECRBT6eE=;
        b=Tl6EAsN8pOffWm/Kr+pwaa7pF0GO2mlZa6ZnwIHFKxhEYwm79I1+2ZDkAepAyx4n3B
         mVQ/egzJIzadA7XK+7JmrD23DzCzKD2BDCHWETSJTKRZZ+2i9FqEqGiBW4DxzjatlTBk
         8QbExH0JDUnSc7AUpDJflKVnpYmx4b/K4rM9a4RCP0aftHvN+rJhwDr6lNWhZr+bWNKP
         q95BQ1ygLlztCpLeZ6ZxaAmF6oRdtIvO6nylX+do2VtB2YtKWtFJb5i5WGADCT7MBTMf
         1y3uYtXQ/GbcZU8lPCLNNeIwLCmb6ks3s4XHkgaa9LedX8ddJzkTMBxPAef3rG2u1bsr
         RFNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVqS4pihVwtQ6+HCwPZ5f/eBCy9xewit8WMaolqxak9bnYT0r+V
	yR093VI5Dh0fOCOHXysZANYtw5usaVt7MJKYU38SZTP+VagSjBjbyq5veYib4zyjJhmUW1JTfC/
	XaOCAL7o9QeUmOrIxw0XsHF/hS8r0kWimURk+MGpsBET4a4zUfd3X4yV5NFBtzZI2yQ==
X-Received: by 2002:a17:902:2e81:: with SMTP id r1mr7155296plb.278.1551472866779;
        Fri, 01 Mar 2019 12:41:06 -0800 (PST)
X-Google-Smtp-Source: APXvYqw5ygquol8jfXMSJ2Im3ahls8RaKn1s3yPvM//o6/tzYbX8ZQLNzovnMERWNx11Z+YI4U3M
X-Received: by 2002:a17:902:2e81:: with SMTP id r1mr7155206plb.278.1551472865647;
        Fri, 01 Mar 2019 12:41:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551472865; cv=none;
        d=google.com; s=arc-20160816;
        b=GCy2u5jhRgBh4n2ojbUzzXsIE2qnycfijVDwKZlGyCRiF7fDWx/KHDLQLIP3b3gvJm
         s3qkymVXWq3LcZB5merHL/sJrswMEHiWe8gbTPbry57x1Ffe/WXyPpjaMVeorfbRoyjt
         Fk4sk08397T//TZAosTR9RbPSwc8M5cUuxKBp/NtSWheQ/4s1UCjsYvlhqW4XIXG4fP6
         xV2m/7cQzNPhdH7zRSlGzZNaB2m9denBwuVEZo5R3C90Xmn1Q1Z41ZVp1T2tpUxP+VM1
         wVwCOxhysX3VXyXsoRir5hJFkPjxnVCZO7efw/tYeB3S5K0RR1AhlgF4ig9Xrg0YziAQ
         jxTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=dU0QwGT/3+ioq223MyX/qmthmGilAo6Jq4PECRBT6eE=;
        b=uezEPvPiqukZKMEXlD21+Fm3pDqzlxFCmCPURaDl9v1DPVW0pKCPINMTWIGYIrq5Ms
         gZZblMICWdkaBaoYHom6jDPYUJe/xhzhoX0KZD7wMRd1JyZiRI6w6+WFsBDeS14YzBlY
         Y7DyQ8xdbzNXhhjXKzsTkxclgceDr4IkuyLLuYL7xmZgQsNQLIblZM3XRMILniiE54Uk
         vdQaNOMp/+ngXJaXx07deyYCHSiv15yK/+pJZPXtvKvPCfdLVdLOGL/X/qQ6UTMzw+HD
         lzYicVfmalCrf4HPawl4iI7L3lvGyj35tY04c2joCCspC2dLphveB/ry/AwnPW6v87+O
         HkcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r187si16919704pfr.124.2019.03.01.12.41.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 12:41:05 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 58A0AD819;
	Fri,  1 Mar 2019 20:41:04 +0000 (UTC)
Date: Fri, 1 Mar 2019 12:41:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Guillaume Tucker <guillaume.tucker@collabora.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>,
 Mark Brown <broonie@kernel.org>, Tomeu Vizoso <tomeu.vizoso@collabora.com>,
 Matt Hart <matthew.hart@linaro.org>, Stephen Rothwell
 <sfr@canb.auug.org.au>, khilman@baylibre.com, enric.balletbo@collabora.com,
 Nicholas Piggin <npiggin@gmail.com>, Dominik Brodowski
 <linux@dominikbrodowski.net>, Masahiro Yamada
 <yamada.masahiro@socionext.com>, Kees Cook <keescook@chromium.org>, Adrian
 Reber <adrian@lisas.de>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux
 MM <linux-mm@kvack.org>, Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>, Richard Guy Briggs <rgb@redhat.com>,
 "Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
Message-Id: <20190301124100.62a02e2f622ff6b5f178a7c3@linux-foundation.org>
In-Reply-To: <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
	<20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
	<20190215185151.GG7897@sirena.org.uk>
	<20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
	<CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
	<20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
	<CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
	<026b5082-32f2-e813-5396-e4a148c813ea@collabora.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Mar 2019 09:25:24 +0100 Guillaume Tucker <guillaume.tucker@collabora.com> wrote:

> >>> Michal had asked if the free space accounting fix up addressed this
> >>> boot regression? I was awaiting word on that.
> >>
> >> hm, does bot@kernelci.org actually read emails?  Let's try info@ as well..
> 
> bot@kernelci.org is not person, it's a send-only account for
> automated reports.  So no, it doesn't read emails.
> 
> I guess the tricky point here is that the authors of the commits
> found by bisections may not always have the hardware needed to
> reproduce the problem.  So it needs to be dealt with on a
> case-by-case basis: sometimes they do have the hardware,
> sometimes someone else on the list or on CC does, and sometimes
> it's better for the people who have access to the test lab which
> ran the KernelCI test to deal with it.
> 
> This case seems to fall into the last category.  As I have access
> to the Collabora lab, I can do some quick checks to confirm
> whether the proposed patch does fix the issue.  I hadn't realised
> that someone was waiting for this to happen, especially as the
> BeagleBone Black is a very common platform.  Sorry about that,
> I'll take a look today.
> 
> It may be a nice feature to be able to give access to the
> KernelCI test infrastructure to anyone who wants to debug an
> issue reported by KernelCI or verify a fix, so they won't need to
> have the hardware locally.  Something to think about for the
> future.

Thanks, that all sounds good.

> >> Is it possible to determine whether this regression is still present in
> >> current linux-next?
> 
> I'll try to re-apply the patch that caused the issue, then see if
> the suggested change fixes it.  As far as the current linux-next
> master branch is concerned, KernelCI boot tests are passing fine
> on that platform.

They would, because I dropped
mm-shuffle-default-enable-all-shuffling.patch, so your tests presumably
now have shuffling disabled.

Is it possible to add the below to linux-next and try again?

Or I can re-add this to linux-next.  Where should we go to determine
the results of such a change?  There are a heck of a lot of results on
https://kernelci.org/boot/ and entering "beaglebone-black" doesn't get
me anything.

Thanks.



From: Dan Williams <dan.j.williams@intel.com>
Subject: mm/shuffle: default enable all shuffling

Per Andrew's request arrange for all memory allocation shuffling code to
be enabled by default.

The page_alloc.shuffle command line parameter can still be used to disable
shuffling at boot, but the kernel will default enable the shuffling if the
command line option is not specified.

Link: http://lkml.kernel.org/r/154943713572.3858443.11206307988382889377.stgit@dwillia2-desk3.amr.corp.intel.com
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Keith Busch <keith.busch@intel.com>

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 init/Kconfig |    4 ++--
 mm/shuffle.c |    4 ++--
 mm/shuffle.h |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

--- a/init/Kconfig~mm-shuffle-default-enable-all-shuffling
+++ a/init/Kconfig
@@ -1709,7 +1709,7 @@ config SLAB_MERGE_DEFAULT
 	  command line.
 
 config SLAB_FREELIST_RANDOM
-	default n
+	default y
 	depends on SLAB || SLUB
 	bool "SLAB freelist randomization"
 	help
@@ -1728,7 +1728,7 @@ config SLAB_FREELIST_HARDENED
 
 config SHUFFLE_PAGE_ALLOCATOR
 	bool "Page allocator randomization"
-	default SLAB_FREELIST_RANDOM && ACPI_NUMA
+	default y
 	help
 	  Randomization of the page allocator improves the average
 	  utilization of a direct-mapped memory-side-cache. See section
--- a/mm/shuffle.c~mm-shuffle-default-enable-all-shuffling
+++ a/mm/shuffle.c
@@ -9,8 +9,8 @@
 #include "internal.h"
 #include "shuffle.h"
 
-DEFINE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
-static unsigned long shuffle_state __ro_after_init;
+DEFINE_STATIC_KEY_TRUE(page_alloc_shuffle_key);
+static unsigned long shuffle_state __ro_after_init = 1 << SHUFFLE_ENABLE;
 
 /*
  * Depending on the architecture, module parameter parsing may run
--- a/mm/shuffle.h~mm-shuffle-default-enable-all-shuffling
+++ a/mm/shuffle.h
@@ -19,7 +19,7 @@ enum mm_shuffle_ctl {
 #define SHUFFLE_ORDER (MAX_ORDER-1)
 
 #ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
-DECLARE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
+DECLARE_STATIC_KEY_TRUE(page_alloc_shuffle_key);
 extern void page_alloc_shuffle(enum mm_shuffle_ctl ctl);
 extern void __shuffle_free_memory(pg_data_t *pgdat);
 static inline void shuffle_free_memory(pg_data_t *pgdat)
_

