Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E962AC31E46
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 01:30:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85734215EA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 01:30:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2ZR5cg5q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85734215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB42C6B000D; Wed, 12 Jun 2019 21:30:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E65A36B000E; Wed, 12 Jun 2019 21:30:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7B776B0010; Wed, 12 Jun 2019 21:30:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0746B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 21:30:18 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i33so10875747pld.15
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:30:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=A1BK2qUzTenfWRcSanHn4HxwaH8D0/dFbehXHckrPD0=;
        b=Lt0zeHis84vAtgV3k+Y15tFl3nD6P+/t5CrR5B0WmRdGsy0thpdpafKSNEFXXTnNYq
         RL+S4kNi+TTBLN5P6Yhd3R8JXQRlQH9ji8RVupiIu/boqgocUBfEabaa3DdVRXrc2pHg
         BxLK18OYynaoFrHb2BEBE0Lro+7YPillBSnsRnIVjCfTrOuzZMAjABL4xdFauz/syGrK
         Vv3a4jdRxqy9mv9WLTFTWy8Gr+WpKUSD8DvIxQoRgEfMa7t4lsJ3TqqhrjEQ3CpsZDQ8
         Q7+J/32lLkAw0qQeQKDV2uHE4L9IRg6RLomFsCGJZ6mEeTy1ZAhpgp1chcXkzwPPc8Ww
         VHng==
X-Gm-Message-State: APjAAAUKukjzw/RUoviuYsLSrtCMjhB8eUVYt3snHuLkH0SIrsp2zxqK
	7UICTa9Ba+VQ0zUMLIVTKHNHesjNQa44jMV+dHh0bPjIg6CyFR5JmIrAKxd5W2KrfuFYm2yQm7Q
	atQgeEim8bm+N2HCBE8gUj+ZZgB1K3Br6MFdb4iwktPIZue78DqyYJCS1yEnxhP1XzQ==
X-Received: by 2002:a63:6f8d:: with SMTP id k135mr27975925pgc.118.1560389418101;
        Wed, 12 Jun 2019 18:30:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4tUxtmLeFk0H4ibRxbJ2O+FClNQ5KNrjDK0l37PyCOKLHiRoOsAG4857Vroh3s8jXVttf
X-Received: by 2002:a63:6f8d:: with SMTP id k135mr27975859pgc.118.1560389417186;
        Wed, 12 Jun 2019 18:30:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560389417; cv=none;
        d=google.com; s=arc-20160816;
        b=hDInyRxF7BQ1QgPuWBottbAlcHiEITdbI0fKuUMPMW1b8gQ96ADEVty678H6dKKIvG
         Zb0ukaRyP/W4xTiSbfB30q4DiIBoD4pSTMbOhblylWz3z5gU3yRyd0BMgpDi4MuhObT4
         /y2I+CGNE8W+nNH10DgWHfe1Nfp6pc2etUeiwVCLTiYUHR5bT8C46Aw3OIIfzP+uDbmP
         SwiXJiyDozHiEIsRc/XL9fafhF8EHGc8pvbyFEWC3T5xTfCXVfBZnfoGD+Ezxj2qFH+f
         KU8XusDlptQExj4NDvJ65UJOsw3fwqTtSnBU4i42IpWBld/1s8r0O8PzRyNZQjulLHMv
         IIEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=A1BK2qUzTenfWRcSanHn4HxwaH8D0/dFbehXHckrPD0=;
        b=0McmOEdPjfbNTN+hWg7hFxo6S4LMqE6xxiAQDnQttHnMUvneqFuUi/EhvsQYD824ck
         IAbaxQ9Rv2A45fNm5t5DWDfYSwQ/705gh/VE3/qLVbgKZJ32pdH7XxYQ7H0rgwZP3+7l
         cFfxsjHC/6rTHd3ylYf6TqfIloLlksT7ENJlxB3gg3Z+Hb5523x6ZoxfJnzC8Dxwk/a2
         1ipSferujcZ7ll80NMcTMe1uSCKT2wsqxSLqjoltn70ZomzeU4Opczc5tKTNiaIcQJv4
         7lSpLJxi0f1v4/OdniFugIJcU2cTdIshaAJq0Q2szPhQ33GQOnBO2B7Jnk2P56zO+wBc
         hIIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2ZR5cg5q;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q10si1072144plr.412.2019.06.12.18.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 18:30:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2ZR5cg5q;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 910D621721
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:30:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560389416;
	bh=245hSvEJ1fyVQ/NUoZsypuMJ69r/WWckga7/iHsIA6Q=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=2ZR5cg5qXeIW8QeSueU+v+XoVtJwJqgh/zbPK+Vh23DiNB76z6igVBk5QmFjC4Q/b
	 GYn8i0J6URP72JalBhebTaSz6TzlBV+Qnr5O7B+twJgiUQVPaKaKwsqofehUrHIiSR
	 AYRWMsmaxcXIZJR9IifMDN2N37eieMRhYyWPJmug=
Received: by mail-wr1-f49.google.com with SMTP id v14so18849238wrr.4
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:30:16 -0700 (PDT)
X-Received: by 2002:adf:ef48:: with SMTP id c8mr35692572wrp.352.1560389415200;
 Wed, 12 Jun 2019 18:30:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190612170834.14855-1-mhillenb@amazon.de> <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
In-Reply-To: <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 12 Jun 2019 18:30:03 -0700
X-Gmail-Original-Message-ID: <CALCETrXHbS9VXfZ80kOjiTrreM2EbapYeGp68mvJPbosUtorYA@mail.gmail.com>
Message-ID: <CALCETrXHbS9VXfZ80kOjiTrreM2EbapYeGp68mvJPbosUtorYA@mail.gmail.com>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM secrets
To: Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>
Cc: Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 1:27 PM Andy Lutomirski <luto@amacapital.net> wrote=
:
>
>
>
> > On Jun 12, 2019, at 12:55 PM, Dave Hansen <dave.hansen@intel.com> wrote=
:
> >
> >> On 6/12/19 10:08 AM, Marius Hillenbrand wrote:
> >> This patch series proposes to introduce a region for what we call
> >> process-local memory into the kernel's virtual address space.
> >
> > It might be fun to cc some x86 folks on this series.  They might have
> > some relevant opinions. ;)
> >
> > A few high-level questions:
> >
> > Why go to all this trouble to hide guest state like registers if all th=
e
> > guest data itself is still mapped?
> >
> > Where's the context-switching code?  Did I just miss it?
> >
> > We've discussed having per-cpu page tables where a given PGD is only in
> > use from one CPU at a time.  I *think* this scheme still works in such =
a
> > case, it just adds one more PGD entry that would have to context-switch=
ed.
>
> Fair warning: Linus is on record as absolutely hating this idea. He might=
 change his mind, but it=E2=80=99s an uphill battle.

I looked at the patch, and it (sensibly) has nothing to do with
per-cpu PGDs.  So it's in great shape!

Seriously, though, here are some very high-level review comments:

Please don't call it "process local", since "process" is meaningless.
Call it "mm local" or something like that.

We already have a per-mm kernel mapping: the LDT.  So please nix all
the code that adds a new VA region, etc, except to the extent that
some of it consists of valid cleanups in and of itself.  Instead,
please refactor the LDT code (arch/x86/kernel/ldt.c, mainly) to make
it use a more general "mm local" address range, and then reuse the
same infrastructure for other fancy things.  The code that makes it
KASLR-able should be in its very own patch that applies *after* the
code that makes it all work so that, when the KASLR part causes a
crash, we can bisect it.

+ /*
+ * Faults in process-local memory may be caused by process-local
+ * addresses leaking into other contexts.
+ * tbd: warn and handle gracefully.
+ */
+ if (unlikely(fault_in_process_local(address))) {
+ pr_err("page fault in PROCLOCAL at %lx", address);
+ force_sig_fault(SIGSEGV, SEGV_MAPERR, (void __user *)address, current);
+ }
+

Huh?  Either it's an OOPS or you shouldn't print any special
debugging.  As it is, you're just blatantly leaking the address of the
mm-local range to malicious user programs.

Also, you should IMO consider using this mechanism for kmap_atomic().
Hi, Nadav!

