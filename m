Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 869DAC31E5D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:53:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EA13208C4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:53:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="eXbR6IGl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EA13208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B417A8E0004; Mon, 17 Jun 2019 14:53:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACAF78E0001; Mon, 17 Jun 2019 14:53:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9938C8E0004; Mon, 17 Jun 2019 14:53:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2B48E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 14:53:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r142so7579642pfc.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:53:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=V33gFYBC1xUvo+Vd4Wqvv3K5sNksw5k/BUi3Ex5l8XM=;
        b=KtSKuK+2DUIMbMiJIVOWWyW8efjxW5yoJOuh/0tJSGEllitJlCVvxiP2WBB3NxMRcd
         lHrj0rZv1BEqTuss0M3v2+6zO41RJMkk+daYHINy8Tg0z9raaASJ7MpJnvaUKdViFfTX
         e2T42NGFZCCS1Cxkfr/AJq/NK7l8EOz78hYWSyt13KUoIvExD7I0P2Ixrc0rM1Gs/Slf
         VffAvBYwqx6dQNWwY42MpW20Sf8QiJ+poM5/Hqq7gVTq4Xn1X0OhiWzZSR1zdMxi/ykf
         fMTyElhNhnvkAMvmkSql3zq8gMVjLtiZ9H6LI8jNpqFNWNAwbeYa+gqPSEWoN2ILoTyw
         GyYg==
X-Gm-Message-State: APjAAAWOSlxNyx0lh2fmpD1M+E8pfhzsV706odU++/Ksny2ZPFngYEnA
	3muRPvrzxodWmeZq/xcl0T/vurDkN0myKFoKSy4GN82/GGvrTvmdmh5Cqfr+Ly+UqHyML1KPsym
	4t3vNY6rZBfwDAsxllMsKuNezF0F6LiSTeWWR3W2myZWSwe15FJz25/g6lmi5fKUPnQ==
X-Received: by 2002:a17:90a:aa0d:: with SMTP id k13mr286974pjq.53.1560797618057;
        Mon, 17 Jun 2019 11:53:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbbkiOnp2A4BX7QZ0Drocx8+jRnk1Qvf9VYkYo7V6d64t4SylomN6OEwZWIMUiFFtYGFKZ
X-Received: by 2002:a17:90a:aa0d:: with SMTP id k13mr286903pjq.53.1560797617244;
        Mon, 17 Jun 2019 11:53:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560797617; cv=none;
        d=google.com; s=arc-20160816;
        b=caP4nMcSY8Pu7DHrD3qxKz0gNiHJpaTJ78/wd8QiuT5qEQzQviJzw37L9uzMyhaZXf
         /aXJgRK0S5kwaIzEPpffUiTFEAZb5ilgH8cK6Dbt/t+Wmovg6zy6eda3BD55Qz0b7kMu
         W8XH1bgJXIYBiiTI19sDa39l5qsPY5rcF2GTC7SeEG9SUekQqiKJvbHzijTAx7GA5FBy
         h440qOtwL1Lmlp4AIJk9QQgDlzEdIMNrch7f98f3rtBFdlyH4/iJo5v7Pm+YWsJ5c+Db
         j7pQmdKIgM4Pa5ybp5RZqGhFYZpKXxo8z8XXbWzOmXnrhM/nKpARyU7T5J3SwuLKBZi8
         h9Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=V33gFYBC1xUvo+Vd4Wqvv3K5sNksw5k/BUi3Ex5l8XM=;
        b=UygY+SqW6wMjGzGjUlPJYckVtXyqE6AyCpjF3sKhIsst6C2D1YXrP6uQ+kOs7pCeZG
         TucjRpYwE43mROixvniQEEZR8z1+WkztrFRstIy25NilVsSC+ZMFePPQwylK51q9T1Uo
         wuQwWbZ7bJkUL0pUsVDIRQ8Q8oYYt2OzF+ThrjXCjmj6Eax5FMhUlma5HpAMHcnmp4/N
         CTdD1CQoV9840tyS8DnpDREoQQ4GYZTeFYnaqjoL1ULfSgQxeis+cSxUQh/Fwn+EnPfg
         rsO2eCU+Rif4w976zQTft6vBRCg3Pjc+WoKxHKA7sNVsgQ3pQ4jz5I4hJCJHr4/uzMsd
         RRMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=eXbR6IGl;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o63si83129pjo.94.2019.06.17.11.53.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 11:53:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=eXbR6IGl;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A38922147A
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:53:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560797616;
	bh=lKC3JNmm/M1af0c1PRbg2Uh820jqPX+NRIxEKPybN6M=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=eXbR6IGlAhoRHsh0X3dKP72UYrrHCysviqVduIvo988BvFsDJiHNmagNTuqCgT0Tz
	 Ehk6WcbvY4nPlIO+gF1eI6ULC/OMuVOV6cx+LReTSeqmIaWk3PzySvWxhGGeBAAkMp
	 4syFIFuC1xSZZCiJ/kFMwEe46IZHRSe0NOBIJQfw=
Received: by mail-wr1-f46.google.com with SMTP id r16so11132302wrl.11
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:53:36 -0700 (PDT)
X-Received: by 2002:a5d:6207:: with SMTP id y7mr56496191wru.265.1560797615195;
 Mon, 17 Jun 2019 11:53:35 -0700 (PDT)
MIME-Version: 1.0
References: <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net> <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
 <58788f05-04c3-e71c-12c3-0123be55012c@amazon.com> <63b1b249-6bc7-ffd9-99db-d36dd3f1a962@intel.com>
 <CALCETrXph3Zg907kWTn6gAsZVsPbCB3A2XuNf0hy5Ez2jm2aNQ@mail.gmail.com>
 <698ca264-123d-46ae-c165-ed62ea149896@intel.com> <CALCETrVt=X+FB2cM5hMN9okvbcROFfT4_KMwaKaN2YVvc7UQTw@mail.gmail.com>
 <5AA8BF10-8987-4FCB-870C-667A5228D97B@gmail.com> <f6f352ed-750e-d735-a1c9-7ff133ca8aea@intel.com>
 <20190617184536.GB11017@char.us.oracle.com>
In-Reply-To: <20190617184536.GB11017@char.us.oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 11:53:22 -0700
X-Gmail-Original-Message-ID: <CALCETrVhg8FquaB6tDssEfbPZFV3w0r-+3LPsNsYw26t+_2MMw@mail.gmail.com>
Message-ID: <CALCETrVhg8FquaB6tDssEfbPZFV3w0r-+3LPsNsYw26t+_2MMw@mail.gmail.com>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM secrets
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Andy Lutomirski <luto@kernel.org>, Alexander Graf <graf@amazon.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 11:44 AM Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
>
> On Mon, Jun 17, 2019 at 11:07:45AM -0700, Dave Hansen wrote:
> > On 6/17/19 9:53 AM, Nadav Amit wrote:
> > >>> For anyone following along at home, I'm going to go off into crazy
> > >>> per-cpu-pgds speculation mode now...  Feel free to stop reading now. :)
> > >>>
> > >>> But, I was thinking we could get away with not doing this on _every_
> > >>> context switch at least.  For instance, couldn't 'struct tlb_context'
> > >>> have PGD pointer (or two with PTI) in addition to the TLB info?  That
> > >>> way we only do the copying when we change the context.  Or does that tie
> > >>> the implementation up too much with PCIDs?
> > >> Hmm, that seems entirely reasonable.  I think the nasty bit would be
> > >> figuring out all the interactions with PV TLB flushing.  PV TLB
> > >> flushes already don't play so well with PCID tracking, and this will
> > >> make it worse.  We probably need to rewrite all that code regardless.
> > > How is PCID (as you implemented) related to TLB flushing of kernel (not
> > > user) PTEs? These kernel PTEs would be global, so they would be invalidated
> > > from all the address-spaces using INVLPG, I presume. No?
> >
> > The idea is that you have a per-cpu address space.  Certain kernel
> > virtual addresses would map to different physical address based on where
> > you are running.  Each of the physical addresses would be "owned" by a
> > single CPU and would, by convention, never use a PGD that mapped an
> > address unless that CPU that "owned" it.
> >
> > In that case, you never really invalidate those addresses.
>
> But you would need to invalidate if the process moved to another CPU, correct?
>

There's nothing to invalidate.  It's a different CPU with a different TLB.

The big problem is that you have a choice.  Either you can have one
PGD per (mm, cpu) or you just have one or a few PGDs per CPU and you
change them every time you change processes.  Dave's idea to have one
or two per (cpu, asid) is right, though.  It means we have a decent
chance of context switching without rewriting the whole thing, and it
also means we don't need to write to the one that's currently loaded
when we switch CR3.  The latter could plausibly be important enough
that we'd want to pretend we're using PCID even if we're not.

