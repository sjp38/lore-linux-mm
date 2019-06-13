Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 819E8C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36DFF20665
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:16:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="S+m9ecci"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36DFF20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF7758E0003; Thu, 13 Jun 2019 12:16:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7FA38E0001; Thu, 13 Jun 2019 12:16:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D2F48E0003; Thu, 13 Jun 2019 12:16:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 626618E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:16:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y5so14766593pfb.20
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:16:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=iszxmpLoxk8hLNWxKCnflDXIBWD8hBpgx1UN8472nTg=;
        b=CAL9UBXfDBNLJcpTvj9bZEg86/2D8GFKGW2mVKXww+j9jFheT3KAOOCnOAUGmvARq9
         uhugdZRNnCSPDrMrpPGqysHSDTlNjsSfgGHjmxAffEa7PeNrYd/I+9ugmKSPiw9hIpVi
         /aQpJE3OsxVX4t7flFmDorF08GqxgQcYxl3CeXIhoExsqAxxsY9J6dv+TX5jfBki1ROQ
         /JymUQBP8AFegbtQ/KyGQR14rS5TPPv5lD4BVLPq3GewHd6dtgAE/dG/dK05rp9NNUtz
         JHWIhjkBEhEqQNUhc8dvxtahS8XjWxGD23q3/uLSc0ifu6Bcr2JzrH8s70cwGWIIXjXX
         wU0Q==
X-Gm-Message-State: APjAAAW/1xyeouejs94pXNqJMJ0zOTdI9QD8YeZLkP7ztpZvZjIFKzEf
	SgEIJ9OC0DSRm8rq07MOugT5MiqlCSjXFD9X+Rv+7etcHlgHNs25K+h0Ly9CGJgk6pX5zLzRrcr
	3LIZWeWmMFo6Zq+Bs3ZqbskHdectr7cyVWsCPBoLkoqNJuSi/1EId9lcz6TYUy9z9vA==
X-Received: by 2002:a62:e0c2:: with SMTP id d63mr36961340pfm.60.1560442587017;
        Thu, 13 Jun 2019 09:16:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoBYKjylMlzinUr8jtfUxWiHbSeNEAhRQTZXeXWzeeLKMxO60fZz6V6Lxt2q5LZFUETmW8
X-Received: by 2002:a62:e0c2:: with SMTP id d63mr36961284pfm.60.1560442586216;
        Thu, 13 Jun 2019 09:16:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560442586; cv=none;
        d=google.com; s=arc-20160816;
        b=loTl0T/kg30nq+50UoLfebanibFlFKtdHdSKOrH3svTfjBM10eBcXn0VX+FE/FOtSQ
         erp8dZmfYxvZzEEDGZZdsFu5PoacenGiBvi14fWQ+v/tZAjO8Kmpw0JSvR5r7WlBtAAm
         noesZrKNIgZJK/7GgdAUNLog/Pxc9QUMrrxjh/ZNDzgq0IL39CLPmyaeW66NslhnLaEg
         8bMM3t3pByhnKmY0NAegbtbSPb/ZcCmbfml3rjbqLsMpk4elYYDkpEpLX+q160sTk0Ra
         IWN4QQQ6T7SO2NsaEWG3zfZgo2BbzPlq0WnxSWl+8NsvAsbkXE7ooKRRzVVJ0yYs0CuT
         DQ9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=iszxmpLoxk8hLNWxKCnflDXIBWD8hBpgx1UN8472nTg=;
        b=OTS0fY22iYNTunsueEE1lz//TuIW8l/qdNzXn55biue5/7tBZlIbXhXZ/sxjS3v16P
         e65wqzkm04BEsCj1yawngOcItkGiUVOMWl/8oa0im2kea/HStlemCkwtpSnxyqeuBIiB
         9f3xAdYetsHBienJjkl4uxDilvEhB40bujIxht6qkS5dNIw14J6EKFHW/LEMU6smpc4o
         OpjAal1Z2t+ah9r+Mi+dn35B1ya7eTsBSlN3a7TSPWY2lIGDJsXODlKztKxNONzXWn2R
         M9ABxgxBnaYt9nonE3A2jw4SRhMPf1Mr76mX9JhoUHT+POb7CxQ4gzBcGVB1/n7KujRQ
         9OCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=S+m9ecci;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a14si43525pfo.37.2019.06.13.09.16.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 09:16:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=S+m9ecci;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A24C9208CA
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:16:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560442585;
	bh=6cDE1IQBqECLX/GE3cz5RFhViPVqUCHI2jp+eXTJxAQ=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=S+m9ecci+s1CfUEwQ+LU0pgPcQX0O3+GlhwHwETe4L4Vg3BsI02F7irSlLLhw3vS7
	 756B+c6c/qOr8fuOkfLvDzliqYxc6edRAA7PG9C/WDjGnTy0LFrgkSurMHDC3HpOfy
	 IGmtaoI/YNTpYJfvjPvjM+6c3Cnz+nGSxxXe5xs4=
Received: by mail-wr1-f48.google.com with SMTP id v14so21420044wrr.4
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:16:25 -0700 (PDT)
X-Received: by 2002:a5d:6207:: with SMTP id y7mr40127026wru.265.1560442584209;
 Thu, 13 Jun 2019 09:16:24 -0700 (PDT)
MIME-Version: 1.0
References: <20190612170834.14855-1-mhillenb@amazon.de> <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net> <CALCETrXHbS9VXfZ80kOjiTrreM2EbapYeGp68mvJPbosUtorYA@mail.gmail.com>
 <F05B97DB-34BD-44CF-AC6A-945D7AD39C38@vmware.com>
In-Reply-To: <F05B97DB-34BD-44CF-AC6A-945D7AD39C38@vmware.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 13 Jun 2019 09:16:12 -0700
X-Gmail-Original-Message-ID: <CALCETrUH4xDeyJh9N19Pf4k5ibRG7phCJy8PEfiJbvr6WZL0MA@mail.gmail.com>
Message-ID: <CALCETrUH4xDeyJh9N19Pf4k5ibRG7phCJy8PEfiJbvr6WZL0MA@mail.gmail.com>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM secrets
To: Nadav Amit <namit@vmware.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 6:50 PM Nadav Amit <namit@vmware.com> wrote:
>
> > On Jun 12, 2019, at 6:30 PM, Andy Lutomirski <luto@kernel.org> wrote:
> >
> > On Wed, Jun 12, 2019 at 1:27 PM Andy Lutomirski <luto@amacapital.net> w=
rote:
> >>> On Jun 12, 2019, at 12:55 PM, Dave Hansen <dave.hansen@intel.com> wro=
te:
> >>>
> >>>> On 6/12/19 10:08 AM, Marius Hillenbrand wrote:
> >>>> This patch series proposes to introduce a region for what we call
> >>>> process-local memory into the kernel's virtual address space.
> >>>
> >>> It might be fun to cc some x86 folks on this series.  They might have
> >>> some relevant opinions. ;)
> >>>
> >>> A few high-level questions:
> >>>
> >>> Why go to all this trouble to hide guest state like registers if all =
the
> >>> guest data itself is still mapped?
> >>>
> >>> Where's the context-switching code?  Did I just miss it?
> >>>
> >>> We've discussed having per-cpu page tables where a given PGD is only =
in
> >>> use from one CPU at a time.  I *think* this scheme still works in suc=
h a
> >>> case, it just adds one more PGD entry that would have to context-swit=
ched.
> >>
> >> Fair warning: Linus is on record as absolutely hating this idea. He mi=
ght change his mind, but it=E2=80=99s an uphill battle.
> >
> > I looked at the patch, and it (sensibly) has nothing to do with
> > per-cpu PGDs.  So it's in great shape!
> >
> > Seriously, though, here are some very high-level review comments:
> >
> > Please don't call it "process local", since "process" is meaningless.
> > Call it "mm local" or something like that.
> >
> > We already have a per-mm kernel mapping: the LDT.  So please nix all
> > the code that adds a new VA region, etc, except to the extent that
> > some of it consists of valid cleanups in and of itself.  Instead,
> > please refactor the LDT code (arch/x86/kernel/ldt.c, mainly) to make
> > it use a more general "mm local" address range, and then reuse the
> > same infrastructure for other fancy things.  The code that makes it
> > KASLR-able should be in its very own patch that applies *after* the
> > code that makes it all work so that, when the KASLR part causes a
> > crash, we can bisect it.
> >
> > + /*
> > + * Faults in process-local memory may be caused by process-local
> > + * addresses leaking into other contexts.
> > + * tbd: warn and handle gracefully.
> > + */
> > + if (unlikely(fault_in_process_local(address))) {
> > + pr_err("page fault in PROCLOCAL at %lx", address);
> > + force_sig_fault(SIGSEGV, SEGV_MAPERR, (void __user *)address, current=
);
> > + }
> > +
> >
> > Huh?  Either it's an OOPS or you shouldn't print any special
> > debugging.  As it is, you're just blatantly leaking the address of the
> > mm-local range to malicious user programs.
> >
> > Also, you should IMO consider using this mechanism for kmap_atomic().
> > Hi, Nadav!
>
> Well, some context for the =E2=80=9Chi=E2=80=9D would have been helpful. =
(Do I have a bug
> and I still don=E2=80=99t understand it?)

Fair enough :)

>
> Perhaps you regard some use-case for a similar mechanism that I mentioned
> before. I did implement something similar (but not the way that you wante=
d)
> to improve the performance of seccomp and system-calls when retpolines ar=
e
> used. I set per-mm code area that held code that used direct calls to inv=
oke
> seccomp filters and frequently used system-calls.
>
> My mechanism, I think, is more not suitable for this use-case. I needed m=
y
> code-page to be at the same 2GB range as the kernel text/modules, which d=
oes
> complicate things. Due to the same reason, it is also limited in the size=
 of
> the data/code that it can hold.
>

I actually meant the opposite.  If we had a general-purpose per-mm
kernel address range, could it be used to optimize kmap_atomic() by
limiting the scope of any shootdowns?  As a rough sketch, we'd have
some kmap_atomic slots for each cpu *in the mm-local region*.  I'm not
entirely sure this is a win.

--Andy

