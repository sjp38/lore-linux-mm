Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D8BFC742C2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 14:36:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39B9420863
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 14:36:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="BMU/i0ok"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39B9420863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A73728E0153; Fri, 12 Jul 2019 10:36:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FCC88E00DB; Fri, 12 Jul 2019 10:36:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 877358E0153; Fri, 12 Jul 2019 10:36:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1538E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 10:36:40 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h5so5798792pgq.23
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 07:36:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AUZ+nG48yRgZSNfhP/Rtxt7JrJ9PZivJotzk6lKp9vA=;
        b=f0zOAT074p8dXD8veCLgvslRw28wymMlZUmG2fEkdVyKGzjHt+W+KkH0Euhyeks96A
         wcAW46i7FFbDDQRmMcXST7AKiecTEn6sPWPrdK8yA+I4F12XxnTOca3w0C7WlhrhOHnq
         JyQGPSXH1HWILaSNbaBGfqx56bVVKM8qS1TyiiwSxrXolezeOiG3CpKkYBndA3SgEuCn
         1iqxvqsOlj+h5tliyrcA0i0G/xtwrQm/+0J6SVvgBZtbI9/wd8zCodxe7lMdDRxbJcMB
         /33tg5mmrj7l/HNmOdDCU2lBOFLXyGhgtg3r/09kxb9zyvc0BCE4U6Z9n8oD6pwYey9y
         cKLw==
X-Gm-Message-State: APjAAAXj3zd51fA1u7FbBqM6c8DWQBNzvW+nn4cds2FALz7a+MLz/JLg
	OHEFxKmTMNNG4KXudpcLXzm2kfCK5IONDq+aHNzoEjv2/225V4djZQJwKIuiNVHBNYGd9Uhn1aw
	aLkwuix9rHwbCTtEVKEbYwE3OTamHo7gVKHyuINM/CGm2Jy0qj2aKxoOHSM69SHsaQA==
X-Received: by 2002:a17:90a:a407:: with SMTP id y7mr12194274pjp.97.1562942199815;
        Fri, 12 Jul 2019 07:36:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGyWi21zbazeV+e89TgcPPXLZj/Zz552B+74nky/aDHg0xfba5VWU/n28ys2x+CCQ/JLWy
X-Received: by 2002:a17:90a:a407:: with SMTP id y7mr12194173pjp.97.1562942198615;
        Fri, 12 Jul 2019 07:36:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562942198; cv=none;
        d=google.com; s=arc-20160816;
        b=O7NvHhousrTaesJ8C3tgtHHvVOLjr8RgBq6kd163ufnbm1RZgNPJ6KlFB4naHaluMV
         I1/km+bB/sT3mZTmuz0grrHcVa/M7VnQrtHWocsm0NkB/X1JbSW4j780xnwmslQj8zm9
         b3J40x+7slKJPqy23e32K3onKUmnApILkmhwPB6eTFydPzWDbYK2YfS8p/hv9+/+X4wl
         OHaW/4Dpywl83yIXedWxtDXNvfTh07zQb4BJcVTCAbPtQ8PYnEBHv/jCk66PHomfgcW/
         ZZptF9Sv99ZpacM4/Tyl6814pEYn7ccA2kOzhTw0enCa1FHB9vxULdKBEQduv6ZQochk
         bTxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AUZ+nG48yRgZSNfhP/Rtxt7JrJ9PZivJotzk6lKp9vA=;
        b=ImPhrI4C1U0uPUZ6yW8evFbVV21H5aVp+jc+KRxdalL3lniIHHetcxxp8KLEOcdL7J
         TFWXE6/TL57Wjo0Prpbhb9TCsfVSEtS8u8T7TJvjjYWJnEhZN0Hlgjk5F8TcM48d6REM
         yufdRjPLx4LAWIZ1ei/dR/cu4m6I65kwUONwQkrwE/GemD2Mk2UonYx2EE+r5g2BlCoa
         JgGNVE6NvRJ8MYTdOR7tacJRZkiVB9rqYWHfR/8TDfFbyzOgSLoPSXJLOe+V2g/BwqwT
         zk784BHYl1QBsp5bblb6hhnzNqFHJBHznvVSW7Poqbb6Gjkj2GtchazwIaKWVDCa7opF
         rm5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="BMU/i0ok";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i3si7868596plb.205.2019.07.12.07.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 07:36:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="BMU/i0ok";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D47A72177E
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 14:36:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562942198;
	bh=HHZaY2tFKhZh3Vou4+5i4iiP03K9QdtH44f6+mWjpsU=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=BMU/i0oks+/4c4QxoYHg4VHE+HQvdXAHjhjm8+Y4yt71+/hMS9dEcxx3tElR67tGe
	 7Ciw8GCvF9uol6OSlonEYS3hxruFK/r13XBVes2AggLAR6coK/QrqM8XMN5iOCSyoA
	 M3QKOCfY2ED8hqKUxR3qB7zBFtDmxMIEz3H8XPYk=
Received: by mail-wr1-f51.google.com with SMTP id y4so10254001wrm.2
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 07:36:37 -0700 (PDT)
X-Received: by 2002:adf:a143:: with SMTP id r3mr12152043wrr.352.1562942196223;
 Fri, 12 Jul 2019 07:36:36 -0700 (PDT)
MIME-Version: 1.0
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com> <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com> <20190712125059.GP3419@hirez.programming.kicks-ass.net>
 <a03db3a5-b033-a469-cc6c-c8c86fb25710@oracle.com>
In-Reply-To: <a03db3a5-b033-a469-cc6c-c8c86fb25710@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 12 Jul 2019 07:36:24 -0700
X-Gmail-Original-Message-ID: <CALCETrVcM-SpEqLMJSOdyGuN0gjr+97+cpu2KYneuTv1fJDoog@mail.gmail.com>
Message-ID: <CALCETrVcM-SpEqLMJSOdyGuN0gjr+97+cpu2KYneuTv1fJDoog@mail.gmail.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, 
	Radim Krcmar <rkrcmar@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andrew Lutomirski <luto@kernel.org>, kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>, 
	Alexander Graf <graf@amazon.de>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Paul Turner <pjt@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 6:45 AM Alexandre Chartre
<alexandre.chartre@oracle.com> wrote:
>
>
> On 7/12/19 2:50 PM, Peter Zijlstra wrote:
> > On Fri, Jul 12, 2019 at 01:56:44PM +0200, Alexandre Chartre wrote:
> >
> >> I think that's precisely what makes ASI and PTI different and independent.
> >> PTI is just about switching between userland and kernel page-tables, while
> >> ASI is about switching page-table inside the kernel. You can have ASI without
> >> having PTI. You can also use ASI for kernel threads so for code that won't
> >> be triggered from userland and so which won't involve PTI.
> >
> > PTI is not mapping         kernel space to avoid             speculation crap (meltdown).
> > ASI is not mapping part of kernel space to avoid (different) speculation crap (MDS).
> >
> > See how very similar they are?
> >
> >
> > Furthermore, to recover SMT for userspace (under MDS) we not only need
> > core-scheduling but core-scheduling per address space. And ASI was
> > specifically designed to help mitigate the trainwreck just described.
> >
> > By explicitly exposing (hopefully harmless) part of the kernel to MDS,
> > we reduce the part that needs core-scheduling and thus reduce the rate
> > the SMT siblngs need to sync up/schedule.
> >
> > But looking at it that way, it makes no sense to retain 3 address
> > spaces, namely:
> >
> >    user / kernel exposed / kernel private.
> >
> > Specifically, it makes no sense to expose part of the kernel through MDS
> > but not through Meltdow. Therefore we can merge the user and kernel
> > exposed address spaces.
>
> The goal of ASI is to provide a reduced address space which exclude sensitive
> data. A user process (for example a database daemon, a web server, or a vmm
> like qemu) will likely have sensitive data mapped in its user address space.
> Such data shouldn't be mapped with ASI because it can potentially leak to the
> sibling hyperthread. For example, if an hyperthread is running a VM then the
> VM could potentially access user sensitive data if they are mapped on the
> sibling hyperthread with ASI.

So I've proposed the following slightly hackish thing:

Add a mechanism (call it /dev/xpfo).  When you open /dev/xpfo and
fallocate it to some size, you allocate that amount of memory and kick
it out of the kernel direct map.  (And pay the IPI cost unless there
were already cached non-direct-mapped pages ready.)  Then you map
*that* into your VMs.  Now, for a dedicated VM host, you map *all* the
VM private memory from /dev/xpfo.  Pretend it's SEV if you want to
determine which pages can be set up like this.

Does this get enough of the benefit at a negligible fraction of the
code complexity cost?  (This plus core scheduling, anyway.)

--Andy

