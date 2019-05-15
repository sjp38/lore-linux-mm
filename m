Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 813E1C04E84
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 19:39:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 385862084F
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 19:39:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 385862084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=angband.pl
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF2E36B0005; Wed, 15 May 2019 15:39:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA3AA6B0006; Wed, 15 May 2019 15:39:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABA236B0007; Wed, 15 May 2019 15:39:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63B566B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 15:39:30 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id x1so314818wrd.15
        for <linux-mm@kvack.org>; Wed, 15 May 2019 12:39:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=RWQI7ooJB6AEhEXYXvitvIV+ZHlCXuh/kzqa9I6YGmw=;
        b=UXPd95jiYL8U14qb0K1rODElynfilrr1APjc9iPI+tUE+lEZODLG0DnV62WvI87Oa0
         LY5JcOG05YtiBe4tcSqcp845HFr5HGvrzibCeCDYi0TffQlbTL1NxMRsQGHzlGegAaxK
         zSIbC1bplyWKa4fKI6e1jmj28wDh39bCxfsyGUtMzuBZ/zlB5PLMFhGvECQ02EoiXGD8
         22jIIzlpDtuKSco3NDVUwS0Dg8vNVD9pWY73ecvES1/GxcDZYWh584Xnk/Zdy4QEwL7e
         5zY0brbf2HsJP0CMMYgWM8fxwTIDEeHuaKtIumk1kJPcvhT1Xv6MvxcLlePQZYoRTA0p
         EnAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
X-Gm-Message-State: APjAAAWQVzHkFJocXaLvV4XLHZ38IHCLfwihGb/qKnIJ+ki9Ny2FAfap
	BoqewzV/NBhnu8VXVGI497mdPXhHdUNcQgWG8dvrCD/rN5K+TbFpOb/G/G+urcsnP8U2Uba4zx/
	CQAD0BCgCrRXFC01LgNYgGoZ7dQ2K6ZM1n0j8F4mJY20qwASbabUKgklsB0q/M82OVA==
X-Received: by 2002:adf:bc94:: with SMTP id g20mr8082043wrh.206.1557949169990;
        Wed, 15 May 2019 12:39:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPFKpYcaCmDekf1ImyOmvkR0xMEcWEbO5w5MaUiZr4WUWvzbKHoMTwj2SsqcFotbLGbOvH
X-Received: by 2002:adf:bc94:: with SMTP id g20mr8082005wrh.206.1557949169136;
        Wed, 15 May 2019 12:39:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557949169; cv=none;
        d=google.com; s=arc-20160816;
        b=tx/oKdv4VVcicvL7hp4FDIiJEvhgjdDiTUtjC4XmqLYLDONunrhaZr/JTixmF5yUpM
         61Y0y3oZvPTcd9cGsoo5onATkIbapRR0KaUZcXkKv06Uz94G9EBq71CZG8ig9Qq5eXE9
         t6cSNodJn3Xooz7HEV79q0tiFq2CN3szAlV0RW/GkkWl/dw49KES8aZVPguUb5JkHo+Y
         qgbAcKb6lYZ182aROZ62UaMd3Ly1+PyG4Py7itpzHYzODHproB5ShSpDXlcp1EbJ2lpD
         pS3ENshYSPwmZzt7wGZzTfxfOpaE+gynxVuAcxb82og6I7Fdlm6lVpK3wmfGu3L0hUQ1
         brkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=RWQI7ooJB6AEhEXYXvitvIV+ZHlCXuh/kzqa9I6YGmw=;
        b=RlkBC58We2Fk49clgvngkKptRTZNhn1aV3BNQahWbkGNaQJAq3/bT9q+HtV3kq5E6u
         fOx8tNz/PSS1mqLJoirpBsFcDfVFs/Ci2NPvREjNrrZMJUZT0xqEw+VAXkCIMOQGRA7J
         5BZgWN5dYd+tc3TbMXJxTqRAr48RZZUNd4VzcQa3oE3rujoue0GltkftaO4dF4hGbqI5
         g49CptQLQX5rDiExyYx/j7Qez5onhJmwY+2NjVFYNozzZ1WJsq3aOucMXqFqP8mOuWQt
         2cL0UFNco0pQ21oW/2NLO44RnABUjvtQeqxGgR7jhqrvky3sN1mqh29kO21YqD7bpMWN
         MCMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
Received: from tartarus.angband.pl (tartarus.angband.pl. [2001:41d0:602:dbe::8])
        by mx.google.com with ESMTPS id f198si1975308wme.59.2019.05.15.12.39.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 12:39:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) client-ip=2001:41d0:602:dbe::8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kilobyte@angband.pl designates 2001:41d0:602:dbe::8 as permitted sender) smtp.mailfrom=kilobyte@angband.pl
Received: from kilobyte by tartarus.angband.pl with local (Exim 4.92)
	(envelope-from <kilobyte@angband.pl>)
	id 1hQzjd-0008AI-LV; Wed, 15 May 2019 21:38:41 +0200
Date: Wed, 15 May 2019 21:38:41 +0200
From: Adam Borowski <kilobyte@angband.pl>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
	keith.busch@intel.com, kirill.shutemov@linux.intel.com,
	pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
	ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
	vbabka@suse.cz, cl@linux.com, riel@surriel.com,
	keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
	mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
	aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
	mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
Message-ID: <20190515193841.GA29728@angband.pl>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
X-Junkbait: aaron@angband.pl, zzyx@angband.pl
User-Agent: Mutt/1.10.1 (2018-07-13)
X-SA-Exim-Connect-IP: <locally generated>
X-SA-Exim-Mail-From: kilobyte@angband.pl
X-SA-Exim-Scanned: No (on tartarus.angband.pl); SAEximRunCond expanded to false
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 06:11:15PM +0300, Kirill Tkhai wrote:
> This patchset adds a new syscall, which makes possible
> to clone a mapping from a process to another process.
> The syscall supplements the functionality provided
> by process_vm_writev() and process_vm_readv() syscalls,
> and it may be useful in many situation.
> 
> For example, it allows to make a zero copy of data,
> when process_vm_writev() was previously used:

I wonder, why not optimize the existing interfaces to do zero copy if
properly aligned?  No need for a new syscall, and old code would immediately
benefit.

> There are several problems with process_vm_writev() in this example:
> 
> 1)it causes pagefault on remote process memory, and it forces
>   allocation of a new page (if was not preallocated);
> 
> 2)amount of memory for this example is doubled in a moment --
>   n pages in current and n pages in remote tasks are occupied
>   at the same time;
> 
> 3)received data has no a chance to be properly swapped for
>   a long time.

That'll handle all of your above problems, except for making pages
subject to CoW if written to.  But if making pages writeably shared is
desired, the old functions have a "flags" argument that doesn't yet have a
single bit defined.


Meow!
-- 
⢀⣴⠾⠻⢶⣦⠀ Latin:   meow 4 characters, 4 columns,  4 bytes
⣾⠁⢠⠒⠀⣿⡁ Greek:   μεου 4 characters, 4 columns,  8 bytes
⢿⡄⠘⠷⠚⠋  Runes:   ᛗᛖᛟᚹ 4 characters, 4 columns, 12 bytes
⠈⠳⣄⠀⠀⠀⠀ Chinese: 喵   1 character,  2 columns,  3 bytes <-- best!

