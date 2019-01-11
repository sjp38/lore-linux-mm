Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D32D9C43612
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 00:44:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92595214C6
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 00:44:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0wOYoZuy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92595214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2846A8E0002; Thu, 10 Jan 2019 19:44:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 233AB8E0001; Thu, 10 Jan 2019 19:44:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1237D8E0002; Thu, 10 Jan 2019 19:44:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C974B8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:44:53 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q64so9008004pfa.18
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:44:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AyO2ZUX14HwGnFRVfShkhM/0Ey6IITntw+hlIqJE8Hg=;
        b=s77Cb2x0O4J/9+fOp91ywT3D/p5rf7aIDjvassGLYs6bUxg46hHibRxTseIh19Vlkw
         sjzmAlIIL9OgUrHbT7D0R81XZAvO7FwoT4Wto+KZfqXAtEKxTQYxBQFxr4kBZbARo9ge
         s9BrjPxnJsEsp3fckYhNj2jgwHa6YgPaKASyByrQ1iscwsX2KXIpgd8iekLic5xyyAaJ
         Ms6ZpTakcekuHnMxFatmRSYA302f4URJQ46LRBciRo1PMHuodLfgZyKwb5+FQG5mCeFP
         OHUddj/32tVxKDrDQGX7Y7qIXxcBc3jIb0Z8e4c50QHKuI6LaabULSEaqXIcrQps3dqi
         0vNg==
X-Gm-Message-State: AJcUukcHSC6Bne4sCwmI3GSE6ZCHqqyckm6cKgBPYkTHjbX+4R4kIdss
	tqMYLg07nTmjjPxyXL3PM77RfB5ckHGPGLFQfcz89t1BsDu+1lLN4fg1cjXjJcos71dofp1ZNRI
	5+1Xih/YJkewjKul3rDz9z7/q4ufAi4OLIoQ6KroyjehnnZ+JLIolaA8mIdjF4RhpiA==
X-Received: by 2002:a63:5664:: with SMTP id g36mr9094710pgm.313.1547167493341;
        Thu, 10 Jan 2019 16:44:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Cu8Jv28/inCM5jy4hCZc8lKOpFZUy406iREUx/uQiac8vsv6pdw+G9Um9/4dMm0hpuIrP
X-Received: by 2002:a63:5664:: with SMTP id g36mr9094676pgm.313.1547167492591;
        Thu, 10 Jan 2019 16:44:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547167492; cv=none;
        d=google.com; s=arc-20160816;
        b=xGg2iJ5/zsf2CY7WmXDX7aSeDkAh1XiJLAZApPGxEL96JB8m1HqQSHDWSJxVsdiXBR
         N6FSPTHJwqQ1aPzDVgIo28ZePITN89gDsh1zAfLXME/hcJmgEM7TbOLCx43nkSqAWgwp
         GO6LbdXvIgtIp4GP0PUoZFxUbaV9YXHNMi63FRcDJ4H4hbBXqUDUvPWEjgNwp9o81Wwx
         gvrXquDh+/iwxdHaIr2L3bL7fLKjMPgqBPgMjVc3baR4i8ZiA3bnAAKGQRSQpHnaVq4x
         zo7Mu0tH94FU+u+B2Ig4AlYCL0gbuIuEBJzKC3R8Gg7XUCKwYC+bhCMmZ+4lbRtqIuvd
         ZFQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AyO2ZUX14HwGnFRVfShkhM/0Ey6IITntw+hlIqJE8Hg=;
        b=fecxpPnRVZAeBLGakhshSU3DvB1kaTDVoqu1AV38sLnPIUCxZsbSEa0KY+VG0W9TRd
         NRIzz8fA+4cJKfnPeWCwiGZfufSGMBwaSSGFSlWkT0fmBNUdx7mbzDUiNMqNx0CZNPSZ
         njKSShHe0d6+wp/Gsgw3lEr8evpDzTg8CFxV6EMcCMZgeCiHTbJpFBQii/XmO6u8RVV6
         8ZO32gr9omQCM1S7XGWQkLoHHCN6qkSErvheY1WI1TI+ABYl6psOXmd1tQFtfsPbVzFi
         +WfHJmnevU3zivFmsYWXc2GKzvn/we6Mf66RurRTp+CguDDHlkm7grJeRXW+XZso/9w6
         QGqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0wOYoZuy;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e4si6829871pgl.570.2019.01.10.16.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 16:44:52 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0wOYoZuy;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F19DA218CD
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:44:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1547167492;
	bh=WG/P66XN4qR7HG2MSq1KjFJ2CkSzkKRidv2c1nBua0c=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=0wOYoZuyhSTuDfZfYOyUUB5GM/qZ9DSk4fNQHanVxK9hh7E3mLxhPcUrcR2SZRW5d
	 b4nTmZ8zHmhPcBKNilb5lTl8kgLtNby3D7Z2g4CMUfmtAEdq9iQ09l2y1lGM8zpxvr
	 u+8m/v/cCMoB1KoBZpIdHeGMzLrLmVjZfj6FClYE=
Received: by mail-wr1-f50.google.com with SMTP id x10so13380913wrs.8
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:44:51 -0800 (PST)
X-Received: by 2002:adf:f0c5:: with SMTP id x5mr10938341wro.77.1547167488414;
 Thu, 10 Jan 2019 16:44:48 -0800 (PST)
MIME-Version: 1.0
References: <cover.1547153058.git.khalid.aziz@oracle.com> <CAGXu5jKS8XSw7nByaeXqgPbmRRw01E_zUYxLCk7zFepAVSw_aQ@mail.gmail.com>
In-Reply-To: <CAGXu5jKS8XSw7nByaeXqgPbmRRw01E_zUYxLCk7zFepAVSw_aQ@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 10 Jan 2019 16:44:36 -0800
X-Gmail-Original-Message-ID: <CALCETrVWjdo6C53eFz8Gc99q4HFsGpwf4kDXR5OG8E96t-gSLw@mail.gmail.com>
Message-ID:
 <CALCETrVWjdo6C53eFz8Gc99q4HFsGpwf4kDXR5OG8E96t-gSLw@mail.gmail.com>
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame Ownership
To: Kees Cook <keescook@chromium.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Andy Lutomirski <luto@kernel.org>, 
	Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, 
	Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, 
	Andi Kleen <ak@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, 
	liran.alon@oracle.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, 
	chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, 
	"Woodhouse, David" <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, 
	Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, 
	Joao Martins <joao.m.martins@oracle.com>, Jim Mattson <jmattson@google.com>, 
	pradeep.vincent@oracle.com, John Haxby <john.haxby@oracle.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111004436.Z3J3cqMcwNwmBwdTxoiZjm7OWvrjWolbNIhh3cNw9R0@z>

On Thu, Jan 10, 2019 at 3:07 PM Kees Cook <keescook@chromium.org> wrote:
>
> On Thu, Jan 10, 2019 at 1:10 PM Khalid Aziz <khalid.aziz@oracle.com> wrote:
> > I implemented a solution to reduce performance penalty and
> > that has had large impact. When XPFO code flushes stale TLB entries,
> > it does so for all CPUs on the system which may include CPUs that
> > may not have any matching TLB entries or may never be scheduled to
> > run the userspace task causing TLB flush. Problem is made worse by
> > the fact that if number of entries being flushed exceeds
> > tlb_single_page_flush_ceiling, it results in a full TLB flush on
> > every CPU. A rogue process can launch a ret2dir attack only from a
> > CPU that has dual mapping for its pages in physmap in its TLB. We
> > can hence defer TLB flush on a CPU until a process that would have
> > caused a TLB flush is scheduled on that CPU. I have added a cpumask
> > to task_struct which is then used to post pending TLB flush on CPUs
> > other than the one a process is running on. This cpumask is checked
> > when a process migrates to a new CPU and TLB is flushed at that
> > time. I measured system time for parallel make with unmodified 4.20
> > kernel, 4.20 with XPFO patches before this optimization and then
> > again after applying this optimization. Here are the results:

I wasn't cc'd on the patch, so I don't know the exact details.

I'm assuming that "ret2dir" means that you corrupt the kernel into
using a direct-map page as its stack.  If so, then I don't see why the
task in whose context the attack is launched needs to be the same
process as the one that has the page mapped for user access.

My advice would be to attempt an entirely different optimization: try
to avoid putting pages *back* into the direct map when they're freed
until there is an actual need to use them for kernel purposes.

How are you handing page cache?  Presumably MAP_SHARED PROT_WRITE
pages are still in the direct map so that IO works.

