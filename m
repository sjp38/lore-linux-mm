Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9AF9C43444
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 23:13:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62FE0213F2
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 23:13:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="NTBxXjW1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62FE0213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED7E78E0002; Thu, 10 Jan 2019 18:13:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E88528E0001; Thu, 10 Jan 2019 18:13:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D50E28E0002; Thu, 10 Jan 2019 18:13:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6A648E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:13:20 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id p73so2574499vka.21
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:13:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=pAeQrrPFogb4V7tIaqn4XMzaKAPTBWnl2HVENewfKEs=;
        b=QYBr3vu7TtvAeB3pZXUlcJMQqEapFdDIhK6J4WrG/CInQaMgREdBMMVmNnYef+gYwZ
         VtaSkAX3bNG6bBmXuNuwSBhk+a+NJ8LzYSLjeumbyVjcIk6eMK7v1KbntuyrIuoDpt3G
         2sQoNb/TLKEIPOI+ex8u4fn1yKKk6kWi6WMtjaCrWSSRyWWvrRuhlyO78whz3NxGTXCT
         qA8lEWwwW4nMKL4x8R18/6TBMMef5JSXBLcpYFzNFrBwqPmHRR3M/hAa+fFLuaf8Ufm5
         uHdn3YVpcN/BSG2BbTcbufGicmnHX9ZfkcQvUa4BAyRJ0909+6nZxbyqVwU3KgKnusc9
         w1mg==
X-Gm-Message-State: AJcUukdi3GLTJ8f3mVAVnI7qh4/Ezjzbnva0uSYEq4gy9OPk9Ss0cBjl
	URsl0NNwMKvdL7yZMsr5b+wDcGBn1VbMpYhHYZ4uWAKZIN91EsnBsfiWAgsbcAOvIwGDi2YILvW
	3eXggS/jnQWsMdMu+nuC6ZlPfVuLEOEWlLyNX8L5pii+bub9ikd1I9hnLZER+oKHf5V1HSsYauQ
	msEMZo3GnBujXeBN+t2GmxOwBRTfitL1Q4+A6Z0RtsTmTMfzj3MYbJZKmcqZF0sHODwLI25qVaC
	KZlMyZ3bvTb3OnrSCk9CWQ+MasvkQJnSUEkmgI4oN7kK46KQXz/Nvt6h4li1bA1IzZvHZSR8Gc/
	siVz1afU320wYl83VSripe6vxqLFBDSs2kXzz+Ttk1VvNCuUJTU5KRgRnYr6mxm7sbOcOZWWXSI
	u
X-Received: by 2002:ab0:69ca:: with SMTP id u10mr4331343uaq.57.1547161999924;
        Thu, 10 Jan 2019 15:13:19 -0800 (PST)
X-Received: by 2002:ab0:69ca:: with SMTP id u10mr4331329uaq.57.1547161999036;
        Thu, 10 Jan 2019 15:13:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547161998; cv=none;
        d=google.com; s=arc-20160816;
        b=tx6VZ8jwdZl/r9x5qKLR4JAy4xHdrZoBX9BJ5DafWKWtIfkFSldrD+gTrtjKUoAQ+g
         SxMm1eeWlWJduc3HJC/4t0QxdZGWGp42cbWkv8bwiTkZVyfRPYP8WbBZ/9jgqrhPW85i
         Et4ZhkM1qGDCsWkpxtR90BS466/q1J7k9jlcoOg80qsSZPJa9+i6L8FPwa7ZsyXocork
         KpN19ZKPWnScqGutgv0WBibfjrKBgTPNIeQpIcU+bAVdPp+41Ip5ngBS6CaFh+vtZIVs
         bMoGxFPtfNTQu88Po7qFz4symKrJSGh52GZ33YO9f+thh9f0o9vTt0lTWhXaPi+9HhT/
         XV5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=pAeQrrPFogb4V7tIaqn4XMzaKAPTBWnl2HVENewfKEs=;
        b=kvfrF+XG91bDg8QRN9ZSN58ENqW77rGH+qwPZtcubD7/zmJR52PkvmOv3tPjdeFoCv
         uqeErXYRMoKrLqbyQPtYBvVzLs/A5Xk66PrPUk0yD5CCTUJAP2TvrWBLlbpji3QZREG2
         hFqeGl9OxnawWdi8ROi/3OfNXGWWQmbk92hBtktdOHPJPQdmwT/2trGz98mfoZNw20d3
         GO4m4xpeBCfuV41u+t7AOJyQWmOGtZXn5wdvsgiGQtavMvrlE2hiJu/xwG3iWImAw0PF
         J+r5vCZXxnzzrXlukga34e4ZeEJuQug7vpiJrEPcMArngEH7pKlQczrFb/lUiITU5OQu
         MLUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=NTBxXjW1;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e24sor44339535uah.50.2019.01.10.15.13.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 15:13:18 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=NTBxXjW1;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pAeQrrPFogb4V7tIaqn4XMzaKAPTBWnl2HVENewfKEs=;
        b=NTBxXjW1RJPgt4TrOmul7wCHLaypyr7ulxqdiFmQaTUJ5hUVrp98CVTeGdLkx6Mg6M
         lc286CNT8YqdEEVNztxsP4gTzdUOR4w0by2jt3MUSe7Z8SIRS2AIW5NAiLpN+/Iz7oAm
         tdzFq9f+69udFotzVtHFN1iG1hUJDBuKF1Lrs=
X-Google-Smtp-Source: ALg8bN5qqotSsvxFVZMUAIWLcGOYSBi6khTYOwXNFhW0PH1MtgiEVbN1r4wlocbCbn8Y29FeJ1ICCQ==
X-Received: by 2002:ab0:26cb:: with SMTP id b11mr4412335uap.112.1547161996753;
        Thu, 10 Jan 2019 15:13:16 -0800 (PST)
Received: from mail-vs1-f42.google.com (mail-vs1-f42.google.com. [209.85.217.42])
        by smtp.gmail.com with ESMTPSA id k200sm30916778vke.9.2019.01.10.15.13.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 15:13:16 -0800 (PST)
Received: by mail-vs1-f42.google.com with SMTP id v205so8114304vsc.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:13:16 -0800 (PST)
X-Received: by 2002:a67:e15e:: with SMTP id o30mr5244437vsl.66.1547161670283;
 Thu, 10 Jan 2019 15:07:50 -0800 (PST)
MIME-Version: 1.0
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 10 Jan 2019 15:07:38 -0800
X-Gmail-Original-Message-ID: <CAGXu5jKS8XSw7nByaeXqgPbmRRw01E_zUYxLCk7zFepAVSw_aQ@mail.gmail.com>
Message-ID:
 <CAGXu5jKS8XSw7nByaeXqgPbmRRw01E_zUYxLCk7zFepAVSw_aQ@mail.gmail.com>
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame Ownership
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Ingo Molnar <mingo@kernel.org>, Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, 
	jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>, liran.alon@oracle.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, 
	chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, 
	"Woodhouse, David" <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, 
	Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, 
	joao.m.martins@oracle.com, Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com, 
	John Haxby <john.haxby@oracle.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110230738.9sFNfYGNfqWr2ELY-XToVLhB-4ommWrXBiMZ6Jd5iTI@z>

On Thu, Jan 10, 2019 at 1:10 PM Khalid Aziz <khalid.aziz@oracle.com> wrote:
> I implemented a solution to reduce performance penalty and
> that has had large impact. When XPFO code flushes stale TLB entries,
> it does so for all CPUs on the system which may include CPUs that
> may not have any matching TLB entries or may never be scheduled to
> run the userspace task causing TLB flush. Problem is made worse by
> the fact that if number of entries being flushed exceeds
> tlb_single_page_flush_ceiling, it results in a full TLB flush on
> every CPU. A rogue process can launch a ret2dir attack only from a
> CPU that has dual mapping for its pages in physmap in its TLB. We
> can hence defer TLB flush on a CPU until a process that would have
> caused a TLB flush is scheduled on that CPU. I have added a cpumask
> to task_struct which is then used to post pending TLB flush on CPUs
> other than the one a process is running on. This cpumask is checked
> when a process migrates to a new CPU and TLB is flushed at that
> time. I measured system time for parallel make with unmodified 4.20
> kernel, 4.20 with XPFO patches before this optimization and then
> again after applying this optimization. Here are the results:
>
> Hardware: 96-core Intel Xeon Platinum 8160 CPU @ 2.10GHz, 768 GB RAM
> make -j60 all
>
> 4.20                            915.183s
> 4.20+XPFO                       24129.354s      26.366x
> 4.20+XPFO+Deferred flush        1216.987s        1.330xx
>
>
> Hardware: 4-core Intel Core i5-3550 CPU @ 3.30GHz, 8G RAM
> make -j4 all
>
> 4.20                            607.671s
> 4.20+XPFO                       1588.646s       2.614x
> 4.20+XPFO+Deferred flush        794.473s        1.307xx

Well that's an impressive improvement! Nice work. :)

(Are the cpumask improvements possible to be extended to other TLB
flushing needs? i.e. could there be other performance gains with that
code even for a non-XPFO system?)

> 30+% overhead is still very high and there is room for improvement.
> Dave Hansen had suggested batch updating TLB entries and Tycho had
> created an initial implementation but I have not been able to get
> that to work correctly. I am still working on it and I suspect we
> will see a noticeable improvement in performance with that. In the
> code I added, I post a pending full TLB flush to all other CPUs even
> when number of TLB entries being flushed on current CPU does not
> exceed tlb_single_page_flush_ceiling. There has to be a better way
> to do this. I just haven't found an efficient way to implemented
> delayed limited TLB flush on other CPUs.
>
> I am not entirely sure if switch_mm_irqs_off() is indeed the right
> place to perform the pending TLB flush for a CPU. Any feedback on
> that will be very helpful. Delaying full TLB flushes on other CPUs
> seems to help tremendously, so if there is a better way to implement
> the same thing than what I have done in patch 16, I am open to
> ideas.

Dave, Andy, Ingo, Thomas, does anyone have time to look this over?

> Performance with this patch set is good enough to use these as
> starting point for further refinement before we merge it into main
> kernel, hence RFC.
>
> Since not flushing stale TLB entries creates a false sense of
> security, I would recommend making TLB flush mandatory and eliminate
> the "xpfotlbflush" kernel parameter (patch "mm, x86: omit TLB
> flushing by default for XPFO page table modifications").

At this point, yes, that does seem to make sense.

> What remains to be done beyond this patch series:
>
> 1. Performance improvements
> 2. Remove xpfotlbflush parameter
> 3. Re-evaluate the patch "arm64/mm: Add support for XPFO to swiotlb"
>    from Juerg. I dropped it for now since swiotlb code for ARM has
>    changed a lot in 4.20.
> 4. Extend the patch "xpfo, mm: Defer TLB flushes for non-current
>    CPUs" to other architectures besides x86.

This seems like a good plan.

I've put this series in one of my tree so that 0day will find it and
grind tests...
https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/log/?h=kspp/xpfo/v7

Thanks!

-- 
Kees Cook

