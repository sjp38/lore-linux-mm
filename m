Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27176C31E50
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 22:28:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D99FD20679
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 22:28:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D99FD20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C0DC8E0005; Sun, 16 Jun 2019 18:28:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 671778E0001; Sun, 16 Jun 2019 18:28:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 538F08E0005; Sun, 16 Jun 2019 18:28:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 067E78E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 18:28:34 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id p13so3826622wru.17
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 15:28:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=oQd5Hpi/isAc+2sO8ginUqoNaWpbksszENBw74Ogeq8=;
        b=VdUjmoxCpB0FqC5q3cnOLwmaSJtJsPtdBqaQqukxWMVXIYHBJGYeJCsV04GAiUtV0W
         DSK6FKJJDDemKmCsVyCk4Mj+R9Pln/CvlKmhdlUgJ3ug1oF9wEZKV5tnRArifaReVnzu
         DxvU2zQEPu5PKx06UlVxO/uh60S5bYIvbtb5YwmhZldv7te/fUNSf9YHznYTfO0ysq2J
         xcmBD8GEz2HrCbiXm25FhXKJdpOIiY6i+mNve9Vu6nRV9nyv2IRzpLKa0oNZvCQDKur9
         A4xrwqaza5JjIRnn2EU0Nz3VVzreNbhhWG73XCuykIqZMta2UZtzrH3kHFs+/EVMCtPQ
         p7SA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXWxWYvvQTo9buAoAZNmoilh2EKWOEC1SyRhi8pSiUZfhzmBTbN
	GnebWXyS1vUG242wNJSim4HLMalPvnhx6E9z3C2+Q/hV/k9GZ223wG5mUuu/p+IorZ8fa9/YScG
	xtcj7giTFmyBeLlWDYzUth1XVrONK4mIKJKiUpFrD+NYk2tZe0Y82r/Dly4/oGEgelg==
X-Received: by 2002:a7b:c215:: with SMTP id x21mr16082966wmi.38.1560724113540;
        Sun, 16 Jun 2019 15:28:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzJa/McyFvhk/gG5snKnnorC0r5N5yydslZJZ59pU0YuUmSpQyXJbmoymKpWrCOqpnTyS5
X-Received: by 2002:a7b:c215:: with SMTP id x21mr16082953wmi.38.1560724112754;
        Sun, 16 Jun 2019 15:28:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560724112; cv=none;
        d=google.com; s=arc-20160816;
        b=mQB+6R4zOVkc+1J8hy9z+MViguLzjxIyWv0OBWaxHxbWxyvLXmFN8+1pIaOojleWxZ
         p4fgv98AgwmEUMImEXkIOl0TeJPNTFD8PrQngMhxqIwhjPLaoQYiJcWbJwDvxFPMPZZT
         jC4jvsK8VWQSPGYJE5LqYctp6v/cCcgPGWkrbzun11JcPfXltEbvdgzG0kiyd66QNI7s
         MGFKAvJ3bsnAuKpbeMW/AAAr1mUS+IiokMAQ7NNMd4Jpevi+53JILKxShxp4gEd3Jdv9
         p2eyy7Qnd+peZJPaJNAXderEATB6htk2UJONFviUnfK4zLHidw9uCT10fVS7HiL3evr0
         GXgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=oQd5Hpi/isAc+2sO8ginUqoNaWpbksszENBw74Ogeq8=;
        b=scCsTqk+RN6yG1Mvt+NSXLbsCICvh3hkBKtfkz4I91GddNEIhlfkEfNvbrzwjiK3AK
         beXd+Fg3nmndSd51b/PaKAwIHK/zlNuv/DL+CPetVm6WEcXhQIyIwTO4T06tfBMaCaed
         IWkeZyGGdMTJnInZ052TkCy8hbM0OO8B0xRdIh3OfTC5OLoLGASnaOrM/FAd/zer8q3M
         C0Op1Kbtk4QZN9P9vZl9WyQkAOQC9ssxwx2+FfjnkVXFKxwCLUZAFRN4wlYhHIbmrS1a
         GB+uySlwmvQMaVAS+6gFuKxjoL81QzhXCWCKZyTGHGyRlUK68wmV/fz583rxTgQioYsc
         7J2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z10si8068873wro.431.2019.06.16.15.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 16 Jun 2019 15:28:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from p5b06daab.dip0.t-ipconnect.de ([91.6.218.171] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hcddU-0000Ux-NY; Mon, 17 Jun 2019 00:28:28 +0200
Date: Mon, 17 Jun 2019 00:28:27 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Andy Lutomirski <luto@kernel.org>
cc: Dave Hansen <dave.hansen@intel.com>, 
    Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>, 
    LKML <linux-kernel@vger.kernel.org>, 
    Kernel Hardening <kernel-hardening@lists.openwall.com>, 
    Linux-MM <linux-mm@kvack.org>, Alexander Graf <graf@amazon.de>, 
    David Woodhouse <dwmw@amazon.co.uk>, 
    the arch/x86 maintainers <x86@kernel.org>, 
    Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
In-Reply-To: <CALCETrWZ4qUW+A+YqE36ZJHqJAzxwDgq77bL99BEKQx-=JYAtA@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1906170026370.1760@nanos.tec.linutronix.de>
References: <20190612170834.14855-1-mhillenb@amazon.de> <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com> <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net> <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
 <CALCETrWZ4qUW+A+YqE36ZJHqJAzxwDgq77bL99BEKQx-=JYAtA@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8323329-1576819727-1560724108=:1760"
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000406, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1576819727-1560724108=:1760
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sun, 16 Jun 2019, Andy Lutomirski wrote:
> On Fri, Jun 14, 2019 at 7:21 AM Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Wed, 12 Jun 2019, Andy Lutomirski wrote:
> > >
> > > Fair warning: Linus is on record as absolutely hating this idea. He might
> > > change his mind, but it’s an uphill battle.
> >
> > Yes I know, but as a benefit we could get rid of all the GSBASE horrors in
> > the entry code as we could just put the percpu space into the local PGD.
> >
> 
> I have personally suggested this to Linus on a couple of occasions,
> and he seemed quite skeptical.

The only way to find out is the good old: numbers talk ....

So someone has to bite the bullet, implement it and figure out whether it's
bollocks or not. :)

Thanks,

	tglx

--8323329-1576819727-1560724108=:1760--

