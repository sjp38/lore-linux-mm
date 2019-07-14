Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53DAFC74A44
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 15:06:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F4195214C6
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 15:06:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="v0TmOJxy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F4195214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B9946B0003; Sun, 14 Jul 2019 11:06:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 792C06B0006; Sun, 14 Jul 2019 11:06:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A7176B0007; Sun, 14 Jul 2019 11:06:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35C886B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 11:06:30 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k20so9020957pgg.15
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 08:06:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+PBL1d5NY2furvJE2bI/Vh3LWLA1dlGy0hD3nqDGxC8=;
        b=Fmphux8gY/dtCk0xHiRaLn66hXodQSXUCVq/yA1bHiSP5/nhBl2LG0c7SkadD7SjB3
         1AwzZ8cpcdZ0VMRNeIxIqsuVhy1Ne/S2+xgf+gcyHmWnq8GUM2+2dPFS4gxDQn8xGlg2
         DBgRDVKYL6Sa7azNrU8EXC2gL4AwXj4wFeFRpD/PCrC8ymc/Oel+QIcj+/kyk1To5A2n
         myVvjiGytX065ICWSqy6r9/ayl4peEFWVf4ZbZ3LSP5WmwdAh5rUNq8EJaoMKSvZSaMD
         hUyomEUwDN2gJgWSpZ+dcGzyTdGvzXJVdbgfyC+JV8KF5TT1UIfLT/g1XzKfRD3jFNzw
         KOUQ==
X-Gm-Message-State: APjAAAXxM5/S62SPBOz46TlKsyMHUVZlQXQpF0W+G43mYep/lPlG4WNp
	Nnu7C74KxufMi/tTId7RiyJRSnxojofVB4HRo74wKdumqQq3nCR4ofyLb0EhVW55xcmOmiKtveJ
	JweewH8l7LaUzpIGQGqbMjLsqnZiuVYWqm3RJfQ6XQVNVEvHTSeMxEivytVIMxogDWA==
X-Received: by 2002:a17:90a:37e9:: with SMTP id v96mr23536554pjb.10.1563116789656;
        Sun, 14 Jul 2019 08:06:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyp2L74CffsrAS178DHOL2qo0sUpIwIXbO7D4sIl9M6nP0t+KbMhzzIQv4ze+r55erdRQqm
X-Received: by 2002:a17:90a:37e9:: with SMTP id v96mr23536477pjb.10.1563116788715;
        Sun, 14 Jul 2019 08:06:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563116788; cv=none;
        d=google.com; s=arc-20160816;
        b=C5NWa+EpxCNDl/lHF9ZkPr3Q9NPuWLfE0TlxfsX0BswiyYFrbgW3IGY3UAY5e3TeFr
         rxvOnHgSH5GIwVpeX2mL/42WkEMfDH9TFXdafBb6QO4ROmzXINTnoJi9irtq/b7Dj93Y
         /ViWOjZO67IXj/SBej83bQXCOWzyc3881Xw0mkIZJL3hjt+H4XinMmzeP9pcK2wcaxoZ
         Y5cI+NyLxOEJ37QYh1nJuyq+hybqfkGUwjaQCjBvIfZxcEqH4SEZg1KrDrWKfXoiqJGK
         oydKBT5DSiPI7bxxZBTIFOhoN7wcKMzm82cVxKP/uG9Egefu/DqTIUKwbukp0lws+lac
         rrng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+PBL1d5NY2furvJE2bI/Vh3LWLA1dlGy0hD3nqDGxC8=;
        b=e+ZrxAKJlDGu+lEHlxX6KWWnFDZ+JyST2s2Z+mdarC97A060t9zMHa/mhekVAnihUs
         Sc93zXQny/dGFYax2E+NWv3yQGu5QhhukOOT21TG/M8t88Hxl2dmP5wpyvggFzOMjccr
         cx9sQdah/dDY4D+g/L47oGHQ50COaJIyqfoXz4SKw3UpEU1Uy1bzcP5jHg+dFbjXnR0K
         01Wnq+THjeWvCIVN/Wvc0CIJKASGuHSKlBRcn/oAOsnLdd4DvLmJl6dbWndH7L2YJ1Dx
         7OREBGsPaLRs6pvB+2viESvPSdMi59uHUO7+rfJHnFmdpQ9u0As9OitunA6zTx0h5po0
         0uxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=v0TmOJxy;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f6si10723480pgu.77.2019.07.14.08.06.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 08:06:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=v0TmOJxy;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0C3DA2089C
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 15:06:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563116788;
	bh=9v0TSmLCn8TjvoXn1mqXdhjjoJsiEcxlv4LvLVZbR0I=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=v0TmOJxy83Vs7zwskqPZknhJBHliByWQ9slt88eUlJmFucrdhem7QgBNJjIHsEncL
	 7r1MjLILZtAzjraM7v/6sOCnRImcX93hQrOaGfUCyDDn0RQY7log3hDh3/ibKrYXJj
	 SPkMGaiBSRrNaF/5iAD/xywYdZdj9CsvNJiGqkvg=
Received: by mail-wm1-f46.google.com with SMTP id l2so12790164wmg.0
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 08:06:27 -0700 (PDT)
X-Received: by 2002:a1c:9a53:: with SMTP id c80mr18654369wme.173.1563116786554;
 Sun, 14 Jul 2019 08:06:26 -0700 (PDT)
MIME-Version: 1.0
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com> <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com> <20190712125059.GP3419@hirez.programming.kicks-ass.net>
 <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de>
 <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com> <20190712190620.GX3419@hirez.programming.kicks-ass.net>
In-Reply-To: <20190712190620.GX3419@hirez.programming.kicks-ass.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Sun, 14 Jul 2019 08:06:12 -0700
X-Gmail-Original-Message-ID: <CALCETrWcnJhtUsJ2nrwAqqgdbRrZG6FNLKY_T-WTETL6-B-C1g@mail.gmail.com>
Message-ID: <CALCETrWcnJhtUsJ2nrwAqqgdbRrZG6FNLKY_T-WTETL6-B-C1g@mail.gmail.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, 
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

On Fri, Jul 12, 2019 at 12:06 PM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Fri, Jul 12, 2019 at 06:37:47PM +0200, Alexandre Chartre wrote:
> > On 7/12/19 5:16 PM, Thomas Gleixner wrote:
>
> > > Right. If we decide to expose more parts of the kernel mappings then that's
> > > just adding more stuff to the existing user (PTI) map mechanics.
> >
> > If we expose more parts of the kernel mapping by adding them to the existing
> > user (PTI) map, then we only control the mapping of kernel sensitive data but
> > we don't control user mapping (with ASI, we exclude all user mappings).
> >
> > How would you control the mapping of userland sensitive data and exclude them
> > from the user map? Would you have the application explicitly identify sensitive
> > data (like Andy suggested with a /dev/xpfo device)?
>
> To what purpose do you want to exclude userspace from the kernel
> mapping; that is, what are you mitigating against with that?

Mutually distrusting user/guest tenants.  Imagine an attack against a
VM hosting provider (GCE, for example).  If the overall system is
well-designed, the host kernel won't possess secrets that are
important to the overall hosting network.  The interesting secrets are
in the memory of other tenants running under the same host.  So, if we
can mostly or completely avoid mapping one tenant's memory in the
host, we reduce the amount of valuable information that could leak via
a speculation (or wild read) attack to another tenant.

The practicality of such a scheme is obviously an open question.

