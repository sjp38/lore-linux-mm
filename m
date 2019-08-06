Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C502FC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 22:19:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74E262189E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 22:19:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="meFIABtu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74E262189E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20BE36B0003; Tue,  6 Aug 2019 18:19:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BDE96B0006; Tue,  6 Aug 2019 18:19:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 084326B0007; Tue,  6 Aug 2019 18:19:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C78486B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 18:19:24 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k20so55759674pgg.15
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 15:19:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cLMFtcOvaClrMbvdwLd+qf/TT0K3oNYe27UnDzPlpx0=;
        b=PpjdWlgYzh7bPQh0R4qlLtyptbaHuvEDs97xW+8Bmb+h+TH/1JjMdwp87yFJuleeyU
         xw0CNVxbMaqjmL5XjbrjnWccRLqx/Ca8nEgzo8lOoo2MQv3zGce2tY7WVwlJtM8ymi1Y
         ZCMq6OX7PQQIVXbeqXqhRDc0smEX+NkDCkofxb6HSm8i5jI/RjxG7ANyE4qUlsBet2A+
         OKmxP/Z66VzTrG0AbCHgYBAOAjKIdbO0zyit0XqxN5lMq4vPcxG63NzUNzueExBSsXzr
         uEM7DHf4Eu0gBQrE+gRiwkDfePrDJktmwTNy8PETLBWKzgH0RKhGXmqGuoP/9DdgukWI
         FUCg==
X-Gm-Message-State: APjAAAX0RAzSfLCedvy/nGPH/dHoBx9O0USVVIkOmsm7WV0iJxRqM+8x
	AuXTAoJCK9r6KyF1taDAAZhXoTHMdMEpoaiFVLenY3zW4qoqWiRoZf83RxWT9uNsNq6QYBkVU+H
	hUmsKbc05IHGX0OO2gdkQVqXj7nblA3c1Ehj3D4dAkM/aexQ3bSx9scnX3Bnt1J+IVg==
X-Received: by 2002:aa7:8a92:: with SMTP id a18mr6086965pfc.216.1565129964480;
        Tue, 06 Aug 2019 15:19:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFVVClMBD649/0ABT2VxRJqKkoOc3Rm02dZOjExlqL23++BJBHwbKasqbs4stEH6Wq2u0H
X-Received: by 2002:aa7:8a92:: with SMTP id a18mr6086913pfc.216.1565129963564;
        Tue, 06 Aug 2019 15:19:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565129963; cv=none;
        d=google.com; s=arc-20160816;
        b=ewANjxf8aQjt1oWhJHw3inTYqCfV6zxGQsZdg3Zie9AJD/CB3zkdd1H5eVPJBT1W88
         ntY7eCUlzd+z+/VIDpkd1goM6T14wINIiMz+SJVEVQLssHEWTgoSJYvJODU2zeDAadW4
         qVTffJkSgAendgWMRC4VQmux4eFVcr9k7nAsLIiRA5y7rnPiesLp8e0J/Lou9XkdxBUo
         VLbU0qceaUSXw5Bgtu6bD4wlgIMILEmi3V/EOEFhmH03B2j0xGUusHRPoYiFUR83s+xY
         kuwzwuxtCorfk7VTy0da5ye74P2LgJgl3hU3LOYzMOGNGgrj+dN4bCoSVfGbacXwDdfQ
         47ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cLMFtcOvaClrMbvdwLd+qf/TT0K3oNYe27UnDzPlpx0=;
        b=a6ijeYCtq+T9VhU8kF4su3ZSmfnah/Hw/UqqCKO1/fjxF1OG54ug+DFNPCwFfas1t5
         9yC0RMKzGW2rKt51LXnQLkbSfEfYVNg5gPg4b+QaKkz26FFhE8UQgfSIYe+XZ2ay0Qea
         6fbNUS7rxeOlsvVaeJnyzlHPZ0OxuNy0ubzYlJtBqRHDPAF675qg01i0blMW8474895v
         jHyvtMR/l2IUsY1oPo1o6RkC9nSTYsv9uWtHjZY/U0YFcRpkW0pobUTJWjtufqB3Pxm9
         OugxQIDKIKUdf49V5cQWuxdaU339njwSEpZnr/dXpurGPpIi9ef2CqG6Sck15TLQf25X
         Bszw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=meFIABtu;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j66si43077697plb.375.2019.08.06.15.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 15:19:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=meFIABtu;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AB7B121874;
	Tue,  6 Aug 2019 22:19:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565129963;
	bh=uggloegaAwke9A4UP4qBuMyVFR/d5SRDz42VgcGIwio=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=meFIABtuhORcSvMNLD1Hv0nThWvFZI0Qr53BkMiWwh6sZaACsB8AxS19EWRhOD245
	 XPjeM7EQeanIE0mnWrDAF2RVaT5KRg5MyslBzowrxK7IAG3AckB1mYjDZTe7CHOPId
	 5LjvjYRK0qyrzcwOxuFdWnbt8prbQySEv0+MClOM=
Date: Tue, 6 Aug 2019 15:19:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
 Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>, Catalin
 Marinas <catalin.marinas@arm.com>, Christian Hansen <chansen3@cisco.com>,
 dancol@google.com, fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>, joelaf@google.com, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
 kernel-team@android.com, linux-api@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Mike Rapoport
 <rppt@linux.ibm.com>, minchan@kernel.org, namhyung@google.com,
 paulmck@linux.ibm.com, Robin Murphy <robin.murphy@arm.com>, Roman Gushchin
 <guro@fb.com>, Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
 Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com, Vladimir Davydov
 <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon
 <will@kernel.org>, Brendan Gregg <brendan.d.gregg@gmail.com>
Subject: Re: [PATCH v4 1/5] mm/page_idle: Add per-pid idle page tracking
 using virtual indexing
Message-Id: <20190806151921.edec128271caccb5214fc1bd@linux-foundation.org>
In-Reply-To: <20190805170451.26009-1-joel@joelfernandes.org>
References: <20190805170451.26009-1-joel@joelfernandes.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(cc Brendan's other email address, hoping for review input ;))

On Mon,  5 Aug 2019 13:04:47 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:

> The page_idle tracking feature currently requires looking up the pagemap
> for a process followed by interacting with /sys/kernel/mm/page_idle.
> Looking up PFN from pagemap in Android devices is not supported by
> unprivileged process and requires SYS_ADMIN and gives 0 for the PFN.
> 
> This patch adds support to directly interact with page_idle tracking at
> the PID level by introducing a /proc/<pid>/page_idle file.  It follows
> the exact same semantics as the global /sys/kernel/mm/page_idle, but now
> looking up PFN through pagemap is not needed since the interface uses
> virtual frame numbers, and at the same time also does not require
> SYS_ADMIN.
> 
> In Android, we are using this for the heap profiler (heapprofd) which
> profiles and pin points code paths which allocates and leaves memory
> idle for long periods of time. This method solves the security issue
> with userspace learning the PFN, and while at it is also shown to yield
> better results than the pagemap lookup, the theory being that the window
> where the address space can change is reduced by eliminating the
> intermediate pagemap look up stage. In virtual address indexing, the
> process's mmap_sem is held for the duration of the access.

Quite a lot of changes to the page_idle code.  Has this all been
runtime tested on architectures where
CONFIG_HAVE_ARCH_PTE_SWP_PGIDLE=n?  That could be x86 with a little
Kconfig fiddle-for-testing-purposes.

> 8 files changed, 376 insertions(+), 45 deletions(-)

Quite a lot of new code unconditionally added to major architectures. 
Are we confident that everyone will want this feature?

>
> ...
>
> +static int proc_page_idle_open(struct inode *inode, struct file *file)
> +{
> +	struct mm_struct *mm;
> +
> +	mm = proc_mem_open(inode, PTRACE_MODE_READ);
> +	if (IS_ERR(mm))
> +		return PTR_ERR(mm);
> +	file->private_data = mm;
> +	return 0;
> +}
> +
> +static int proc_page_idle_release(struct inode *inode, struct file *file)
> +{
> +	struct mm_struct *mm = file->private_data;
> +
> +	if (mm)

I suspect the test isn't needed?  proc_page_idle_release) won't be
called if proc_page_idle_open() failed?

> +		mmdrop(mm);
> +	return 0;
> +}
>
> ...
>

