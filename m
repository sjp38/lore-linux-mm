Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEE53C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 23:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A4FC217FA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 23:42:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A4FC217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 464736B0007; Wed, 17 Apr 2019 19:42:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 413BE6B0008; Wed, 17 Apr 2019 19:42:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 303216B000A; Wed, 17 Apr 2019 19:42:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC99E6B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 19:42:43 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id f67so454681wme.3
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 16:42:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=nTplI4lOzcOU1/o/w2xesZThxaJRu4MjYRJby2qPg7w=;
        b=TPZRZCwX2QqQ6it0CTzF1opC1rKasrVdephcPzL/U2vQQE+Rs7xRKzz/Dt4qeHrbQ+
         EpdsEtbpFqJSPlQgEIgZvNACi16+Jt6Ttk7hhgjTcxo3PPjKOUB00jF4b35pGGqVxsmO
         yYO4/SiZ9i170OYMPDCK7WusXR+rkFCLOY+r2T2tm9IPp8McKChTf7MjTQguilDDKmx4
         pMDOJmwjgWPG6dNoWu5vseQKvmjStfyR2vWgVsDkRwRzqMPjs1NdtmI74LJtRKnH8svz
         zf618KdbPjSRYI08I3l5SptqqVEfGI9wMIwwVhLvk3Ga4X4+KdL/X3YSWhJ7MIC46Pgh
         aitg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAW+KNV8wvSJ2UP+Lvf4+7N6FOti9B4h2GGyENsY9JB3q/kyag0p
	Kv2lKxzXh41ql8UAzcYDVLxkcnVdQzHwRtS4arWlf7XS+W8xPZlWa4eZQ57TrMhqB6rFW3sEQmH
	I+gOQaoF3bLfKgTKI1Qbfp2Q3JyJJdsnDCx1ACTVWih4eLuejD1gGfo8VGUBSda8Txw==
X-Received: by 2002:a5d:4d49:: with SMTP id a9mr59598807wru.227.1555544563486;
        Wed, 17 Apr 2019 16:42:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyx1B0mJJUTpDWna1iwhIej239T1sN1d8jW6CeMFWXDd3pLpRU/nYxn9eo7BD6Xk6Gf2VFa
X-Received: by 2002:a5d:4d49:: with SMTP id a9mr59598759wru.227.1555544562432;
        Wed, 17 Apr 2019 16:42:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555544562; cv=none;
        d=google.com; s=arc-20160816;
        b=VU8onT4ZDmLspykjDCF89qEmGBk4pZkRBzZQrJE7FtqxbAjVLAKrkZGb4y7UK9Amwh
         rJPCe2IjnPwBbsufDJbzEFM+/Rh+pveVm+O57wQ0fbT46cUAYkuw90yiDXzOI4hKM0Gu
         Sr9WyJ92a8opbOdQ+tS+1X6sY0XuzHpohoNienr4JQ983q5DEX03MCsSUl2w7+dsHLjn
         IwK05ZR3C/DLAZsaDjbcrb1qTmCx267to9gggPDDdsLXcpwGLFACIhjVmpjUiyy5zGMR
         NAzggX5cHaGNBwd4pmXWXYQhIjlgUCGOUA8V9j8fpYXVpLfXW03Dtchm8kA29LTc4JvC
         6mAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=nTplI4lOzcOU1/o/w2xesZThxaJRu4MjYRJby2qPg7w=;
        b=J9QBRi2WEIAln1LWp6j8pGMjhdjhy0G2f2Kolu2vlvUzVyPNGzfgPth5Eng5Y60bn9
         a/IQh+Vg3YvUS4ranCxFfpOirbz78L0+tadRl2jdxJFV/isEv8iDCLlwwonRopEizGiT
         SF62qBnrnvEgGz9l65EXj0LM4/IcSxELgnM7RlPnXbvVP6Yb5p6EEQ5FZnaha0kvWK73
         SJWh6TnLseuZZNNluIBA5wXnJt+jgePrHnyg8qSKfSMYhsmewB5ePEnnA1PEc8Ab8p3q
         D2JLQSq/l3Pg62bJxBnJL0FvLvKhqnz16tpSRfzc0KnN3+sMQZ0esUbRYKaqAbVpfgP6
         zjHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l5si343962wro.43.2019.04.17.16.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 17 Apr 2019 16:42:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hGuCC-0000Cz-3h; Thu, 18 Apr 2019 01:42:28 +0200
Date: Thu, 18 Apr 2019 01:42:26 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Nadav Amit <nadav.amit@gmail.com>, Ingo Molnar <mingo@kernel.org>, 
    Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com, 
    Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, keescook@google.com, 
    Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, 
    Juerg Haefliger <juerg.haefliger@canonical.com>, 
    deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, 
    David Woodhouse <dwmw@amazon.co.uk>, 
    Andrew Cooper <andrew.cooper3@citrix.com>, jcm@redhat.com, 
    Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
    iommu <iommu@lists.linux-foundation.org>, X86 ML <x86@kernel.org>, 
    linux-arm-kernel@lists.infradead.org, 
    "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
    Linux-MM <linux-mm@kvack.org>, 
    LSM List <linux-security-module@vger.kernel.org>, 
    Khalid Aziz <khalid@gonehiking.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, 
    Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>, 
    "H. Peter Anvin" <hpa@zytor.com>, Arjan van de Ven <arjan@infradead.org>, 
    Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
In-Reply-To: <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1904180129000.3174@nanos.tec.linutronix.de>
References: <cover.1554248001.git.khalid.aziz@oracle.com> <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com> <20190417161042.GA43453@gmail.com> <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com> <20190417170918.GA68678@gmail.com>
 <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com> <20190417172632.GA95485@gmail.com> <063753CC-5D83-4789-B594-019048DE22D9@gmail.com> <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de>
 <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Apr 2019, Linus Torvalds wrote:

> On Wed, Apr 17, 2019, 14:20 Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> >
> > It's not necessarily a W+X issue. The user space text is mapped in the
> > kernel as well and even if it is mapped RX then this can happen. So any
> > kernel mappings of user space text need to be mapped NX!
> 
> With SMEP, user space pages are always NX.

We talk past each other. The user space page in the ring3 valid virtual
address space (non negative) is of course protected by SMEP.

The attack utilizes the kernel linear mapping of the physical
memory. I.e. user space address 0x43210 has a kernel equivalent at
0xfxxxxxxxxxx. So if the attack manages to trick the kernel to that valid
kernel address and that is mapped X --> game over. SMEP does not help
there.

From the top of my head I'd say this is a non issue as those kernel address
space mappings _should_ be NX, but we got bitten by _should_ in the past:)

Thanks,

	tglx


