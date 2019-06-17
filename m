Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0078C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:15:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5E4B20B1F
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:15:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="u0yPsNKY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5E4B20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C8D06B0005; Mon, 17 Jun 2019 12:15:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37B468E0002; Mon, 17 Jun 2019 12:15:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28F4F8E0001; Mon, 17 Jun 2019 12:15:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E7DEA6B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:15:04 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so8040473pgk.16
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:15:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Bg8ht0VYJFjynacTGcfN8uFoIRVey1NJkX8qLdcDQJs=;
        b=q7MQJpJyGTkz8Duq1X4WbEODIA6GcGAxGgQ+iKYyhk02+LYenEd3jqNjAHs9tVYgKX
         zGhKN23U3JthHGlNKkVyMad+MCiGlF2QLXh5zvMBm+1gU1Yg7zsAddKpCzbZ+6aE5pW3
         gFtyOcnGk76r9/DlS6wCED/XBM6HSUw41+RtnCH2t2jRE42Ygny5l/ehA32cQqsAG0Kv
         4SeMWvhe4U5KKlRydqCsaefIFBvKCi7gNXHHXyHyfnQtkOyRgy9YiRnV0LAr/kZJaZrq
         uIWfKmj0cBVck21ikNU5mRqGFTxr3fRvkCsIjt7C4mStYHB2mKw0SabizFuaz4ckxxcp
         J1wg==
X-Gm-Message-State: APjAAAWjzgBRLxtrdl0Kk68/9mS4F9+ghEAPpdViwOrahHtpFQTvk5Ka
	oeO1rsgRMfmvwLXcDbst5wv/dGT5UZWZmGiKaBBeWzjp+O2pg0oLeCy5RF+pH4Y+gsLNt35r4qH
	DsCqXCiGfxuyy2gwjlret+uGenoT2WbctPmyJ4gyZI9AId+QIGMyWLgzEwfI8UkbTyg==
X-Received: by 2002:a63:1c59:: with SMTP id c25mr23663781pgm.395.1560788104542;
        Mon, 17 Jun 2019 09:15:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZcgYI9jWEe3o9hFyjWKWxv2jkflyNlc/e3NFe9b5fPHrpLYKpE4jqaxeMuzjqMdxW5DcP
X-Received: by 2002:a63:1c59:: with SMTP id c25mr23663724pgm.395.1560788103859;
        Mon, 17 Jun 2019 09:15:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560788103; cv=none;
        d=google.com; s=arc-20160816;
        b=Dqs2Cp7AfiRa1iychk5fl4VqUtlM4jBAdsOimPhI+e4Fq2o+FZq3oCzuK37NdJ+CMX
         5m+KxbZZuNSfzT1d/QZCFZ2nEQL7uHwjpDq1oFAhhlGS1DvU1moW6bSzoITqH8Fo+4dg
         oElKesxmekEh2804K5RVzb/rCugkHgTL+cHztED3o9lXyPUIUFKGfpfpgL5FhfmBm4AW
         QnXeuIvPOZ84MskIzptQpT5J91s8KcA1M4a4Xn9TxYDHbXnyG2pJqfR6Vah3iFyk+sGk
         vxEW6YPWAlcQ6vqtxUPcaZLNKIpIK77mA4UD61mytsab2biOkTPvErnEZJ+YpPSRiHxb
         hA1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Bg8ht0VYJFjynacTGcfN8uFoIRVey1NJkX8qLdcDQJs=;
        b=x+Z0B1DM8pK9dYMF1oHpln56YAFBOi76htOhDGpcmgyP1vwhwpGzE0+v8QsNSP+bLt
         RAukykJdgrt1epBNPxioJh8LSikreNbKpvC28RbCD7AGrgDo5XekoIq+cx6No4aLH7bk
         OFmbaEGvb4RmSu17X9+37IPk3C+mRV9KinWqIGtiZNCOPICTEvo1PJNciROrD4pswefq
         yRziPEaGNB318pK7FY0DuqVDJfF99HWZx6NRTO3AtB+a9BC4aflGc8EsI09kW7FfTlX9
         L2D/JCVDfEUzdIh/KOksIkwPClenFt1Yhws2jl/RYWHxT7pxlMU2R2kJNZsWR94OpMid
         RDPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=u0yPsNKY;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q28si10815433pgb.375.2019.06.17.09.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 09:15:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=u0yPsNKY;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 37DDE2147A
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:15:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560788103;
	bh=JVZ01VQ9q2BY9LSCSpDeGenC0gNyM0CCxXIGe7cpTRk=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=u0yPsNKYjsVDPjixo7eGt49hpgnj9Qzul0OjSRqTnkpQP/9jPpaQD4omedpzMB2lr
	 9051sf80GG3JB8m+1Z2RCtEy/6xh2uXK0IsU7wtiqF8+FXMLdRKWfssLvW2hnqbCzC
	 6R4kLuNGpy6jCcaZPdNYXNItJBk70On/mmPqEBsE=
Received: by mail-wr1-f47.google.com with SMTP id n4so10593219wrw.13
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:15:03 -0700 (PDT)
X-Received: by 2002:adf:cc85:: with SMTP id p5mr16200961wrj.47.1560788101765;
 Mon, 17 Jun 2019 09:15:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190612170834.14855-1-mhillenb@amazon.de> <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net> <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
 <58788f05-04c3-e71c-12c3-0123be55012c@amazon.com> <63b1b249-6bc7-ffd9-99db-d36dd3f1a962@intel.com>
 <CALCETrXph3Zg907kWTn6gAsZVsPbCB3A2XuNf0hy5Ez2jm2aNQ@mail.gmail.com> <698ca264-123d-46ae-c165-ed62ea149896@intel.com>
In-Reply-To: <698ca264-123d-46ae-c165-ed62ea149896@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 09:14:50 -0700
X-Gmail-Original-Message-ID: <CALCETrVt=X+FB2cM5hMN9okvbcROFfT4_KMwaKaN2YVvc7UQTw@mail.gmail.com>
Message-ID: <CALCETrVt=X+FB2cM5hMN9okvbcROFfT4_KMwaKaN2YVvc7UQTw@mail.gmail.com>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM secrets
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Alexander Graf <graf@amazon.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>, 
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

On Mon, Jun 17, 2019 at 9:09 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 6/17/19 8:54 AM, Andy Lutomirski wrote:
> >>> Would that mean that with Meltdown affected CPUs we open speculation
> >>> attacks against the mmlocal memory from KVM user space?
> >> Not necessarily.  There would likely be a _set_ of local PGDs.  We could
> >> still have pair of PTI PGDs just like we do know, they'd just be a local
> >> PGD pair.
> >>
> > Unfortunately, this would mean that we need to sync twice as many
> > top-level entries when we context switch.
>
> Yeah, PTI sucks. :)
>
> For anyone following along at home, I'm going to go off into crazy
> per-cpu-pgds speculation mode now...  Feel free to stop reading now. :)
>
> But, I was thinking we could get away with not doing this on _every_
> context switch at least.  For instance, couldn't 'struct tlb_context'
> have PGD pointer (or two with PTI) in addition to the TLB info?  That
> way we only do the copying when we change the context.  Or does that tie
> the implementation up too much with PCIDs?

Hmm, that seems entirely reasonable.  I think the nasty bit would be
figuring out all the interactions with PV TLB flushing.  PV TLB
flushes already don't play so well with PCID tracking, and this will
make it worse.  We probably need to rewrite all that code regardless.

