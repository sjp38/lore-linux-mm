Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1341C10F13
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 00:04:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 244362176F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 00:04:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ouFaE+KB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 244362176F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EA956B026F; Tue, 16 Apr 2019 20:04:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99B876B0270; Tue, 16 Apr 2019 20:04:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 889AF6B0271; Tue, 16 Apr 2019 20:04:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4536B026F
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 20:04:34 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id 70so11716227otn.15
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 17:04:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vwvutNTYcOXRQe3RoAMKK7TXAD1RtScdWgy+YAtCgh8=;
        b=nYN795PgobAjr40yi0Jh23ZySJj4iU9CWrZHGgrTM13KEIF34XrbfSAmckFoahXTti
         O/uaauGeQL2eRx9LeIYb8W94ISUdC+KfFZfhWWEt1Ob9vzWqDynTLvADUgwHzHbF3lzV
         y5jy13ml73Ydibz1tD+W64xtXpJALv+aLpsHtSZ7z0cpWShu55viLuLwWLv0mTxDXEoG
         2h12iq7Ogsd76mcIL/z78MhRDlH1/sZixLn2rdlZBRsoBfAq4m1qxYbXXN/Nk420f8ab
         285wbYxb5R4KmoYcpLjd34btLKH9++1pizfxLRMU2nYwIUlo4wHR0j7vvsSNytvJfSuY
         QVQA==
X-Gm-Message-State: APjAAAWtFOud9e/Atq96vB9Tnsx7s2uZ14ifa+RC3JTmoZdreT5NYs7g
	KgjVlhWjY98CqlAHRUdi/ZANhWp56XoqxxlLx/gVHmdRGCct3J8TbR8vcJpsV8odkCQqV9CpZp7
	AWFMU4fmiwFbiNTJkN4tPEsJ2cQC+D1Zi2My+jarUO+enfNcWcVHEF/YPPrYiVz48/w==
X-Received: by 2002:aca:4dc3:: with SMTP id a186mr25134372oib.19.1555459474035;
        Tue, 16 Apr 2019 17:04:34 -0700 (PDT)
X-Received: by 2002:aca:4dc3:: with SMTP id a186mr25134319oib.19.1555459473250;
        Tue, 16 Apr 2019 17:04:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555459473; cv=none;
        d=google.com; s=arc-20160816;
        b=xTFMqI/gtCUn0+v31X+QOjgkqfzGaeS4Vwe7tVFNn1fdyrce7otMA8IpxNKn8gA2Ez
         xZlpfO1buP/AHx5YTnB6xg11n4ZFsoMkeUWDBVwIn8ALSDVU5DO8a/G/7APjxEcEOlZG
         Q1agqIkzv+4r0HkdCZ06Rq03IqreEJD7x+gYoBI6+YFl6S4gWGhJQ+/6s94e6IXtAlF4
         fm9x5OMScYbJzpp1XXMhUMgNXip44QqabCWehlS2FwzFXfP6NIbIOWmYFadQxSdung7g
         gwxfEYjO3v/xKimM1U+3IZy7zmDa1XliDz9UoEOCWQakglKpqLzLLZ3VbLMC3n74v38H
         5CUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vwvutNTYcOXRQe3RoAMKK7TXAD1RtScdWgy+YAtCgh8=;
        b=W2E0PUyo4Aq5h/JcTVcrUEoNcufvu3FcCIBf5AU6Z+7lg87fKE26qIVNncNRqAW9oj
         VIevLHF5cooeMZPuneZk4z2RmHpqY2Edx3nAFzH3pmcW9yMrGwjehZeiASkZOHSa4ImT
         nmzjlZsqADs9LwC8iwxbHYbYQeF5oMXWX9Tz4y5L1tZFPt/cPw6VfR4Psa3X9y0uHkfB
         DeGmQSHp2MybIeF2JUJJb6PwEP1qQX8XC1LHOoDNZvB0C4X13tcwZ8mWugm3VKo/wDIO
         pWVCtF7sXT0uneVR6cqTfXyfvH7rYqgfq0PnNG9D4q5XiWgkauWf+UI9chMDOPr/qHZa
         CjLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ouFaE+KB;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s125sor26231979oif.105.2019.04.16.17.04.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 17:04:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ouFaE+KB;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vwvutNTYcOXRQe3RoAMKK7TXAD1RtScdWgy+YAtCgh8=;
        b=ouFaE+KBlMmTLWWUDrpOoEUpO+wSy3BeDEMQGztu/P6W+7YYMtu2B/cKvYHGN8/BJe
         lHzcNqMvobiwRNDG/mfnZ1E2gT/UYWuksfdSyEVfPozAU66PS8J/urAiqZJ9RE7MB8FW
         opiSJkphDRt/e6Gx+eSSQtadV85LnlT7VsAdj3fCSGw/wczeKnpniAS6XQNiYxAcJyvG
         j4MfZMTpMUD+VIAShX/G6ddTf8GHTAvYLLATKz3sqlSEAFIHHCZwAHjlIcH0lOGa+q9f
         KRlIXLxlcn3zW/7xjjxL7++Iyk8Up2Fu/9b0opWe7+Wk+ep3XvjFsMBkkZgCUq0oHiP8
         39KQ==
X-Google-Smtp-Source: APXvYqyjthnKh3yftLBP4Zzxceqv6bmhLskpJNNqFMkBqw1sBcZYzu4g11z5X2BE8WBexkGi7yVyfUzbGHvuP7rtG7U=
X-Received: by 2002:aca:d513:: with SMTP id m19mr24770386oig.73.1555459472688;
 Tue, 16 Apr 2019 17:04:32 -0700 (PDT)
MIME-Version: 1.0
References: <155544804466.1032396.13418949511615676665.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190416164418.3ca1d8cef2713a1154067291@linux-foundation.org>
In-Reply-To: <20190416164418.3ca1d8cef2713a1154067291@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 16 Apr 2019 17:04:21 -0700
Message-ID: <CAPcyv4iJxyiGWqjGKLuRgjr9UgDO9ERSghUi3k597gk=X5votQ@mail.gmail.com>
Subject: Re: [PATCH] init: Initialize jump labels before command line option parsing
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Guenter Roeck <groeck@google.com>, 
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Mike Rapoport <rppt@linux.ibm.com>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 4:44 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 16 Apr 2019 13:54:04 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
>
> > When a module option, or core kernel argument, toggles a static-key it
> > requires jump labels to be initialized early. While x86, PowerPC, and
> > ARM64 arrange for jump_label_init() to be called before parse_args(),
> > ARM does not.
> >
> >   Kernel command line: rdinit=/sbin/init page_alloc.shuffle=1 panic=-1 console=ttyAMA0,115200 page_alloc.shuffle=1
> >   ------------[ cut here ]------------
> >   WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:303
> >   page_alloc_shuffle+0x12c/0x1ac
> >   static_key_enable(): static key 'page_alloc_shuffle_key+0x0/0x4' used
> >   before call to jump_label_init()
> >   Modules linked in:
> >   CPU: 0 PID: 0 Comm: swapper Not tainted
> >   5.1.0-rc4-next-20190410-00003-g3367c36ce744 #1
> >   Hardware name: ARM Integrator/CP (Device Tree)
> >   [<c0011c68>] (unwind_backtrace) from [<c000ec48>] (show_stack+0x10/0x18)
> >   [<c000ec48>] (show_stack) from [<c07e9710>] (dump_stack+0x18/0x24)
> >   [<c07e9710>] (dump_stack) from [<c001bb1c>] (__warn+0xe0/0x108)
> >   [<c001bb1c>] (__warn) from [<c001bb88>] (warn_slowpath_fmt+0x44/0x6c)
> >   [<c001bb88>] (warn_slowpath_fmt) from [<c0b0c4a8>]
> >   (page_alloc_shuffle+0x12c/0x1ac)
> >   [<c0b0c4a8>] (page_alloc_shuffle) from [<c0b0c550>] (shuffle_store+0x28/0x48)
> >   [<c0b0c550>] (shuffle_store) from [<c003e6a0>] (parse_args+0x1f4/0x350)
> >   [<c003e6a0>] (parse_args) from [<c0ac3c00>] (start_kernel+0x1c0/0x488)
> >
> > Move the fallback call to jump_label_init() to occur before
> > parse_args(). The redundant calls to jump_label_init() in other archs
> > are left intact in case they have static key toggling use cases that are
> > even earlier than option parsing.
>
> Has it been confirmed that this fixes
> mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization.patch
> on beaglebone-black?

This only fixes dynamically enabling the shuffling on 32-bit ARM.
Guenter happened to run without the mm-only 'force-enable-always'
patch and when he went to use the command line option to enable it he
hit the jump-label warning.

The original beaglebone-black failure was something different and
avoided this case because the jump-label was never used.

I am otherwise unable to recreate the failure on either the original
failing -next, nor on v5.1-rc5 plus the latest state of the patches. I
need from someone who is actually still seeing the failure so they can
compare with the configuration that is working for me. For reference
that's the Yocto beaglebone-black defconfig:

https://github.com/jumpnow/meta-bbb/blob/thud/recipes-kernel/linux/linux-stable-5.0/beaglebone/defconfig

