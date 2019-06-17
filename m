Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18BEEC31E5D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:57:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C872720652
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:57:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HM9XZcRH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C872720652
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618AE8E0001; Mon, 17 Jun 2019 12:57:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CA6E8E0002; Mon, 17 Jun 2019 12:57:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EBCA8E0001; Mon, 17 Jun 2019 12:57:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28C5A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:57:50 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id y70so2426744vsc.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:57:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=retltkRYeaxJ6adF3YGzOCqdGSJ+TnMcYlKByHm/5DU=;
        b=C38TgKHTdu0DR7Y5qNTXcvuaciwModRjwUW2B2V1Htc155zJmwtCXWzI7r8q5+eUdy
         W7TcUpJQMoRrjcKojZ5aJUu984gW6DLB8xT2E9JyA60+Xb2+2+/VifNPvCYWOmhQchIc
         Bm2bCUkYv/zw0f5g55Z5D8IlIhfm22y4po5rKlU2XkEomQs9TekHKoT6siIWSub+OvS3
         ESBMgLmXLjKKZayQBfzIOnvZiswdyc6uOOHqvBFiJXTz7QJj1npZ7EFqrlj6rteut22V
         usCMxElIc8ikq/GjkUECpt7fzUmCZCdNGS7hjEyRaY9E4DX6yLx/otZxoiAjRNGMMNmt
         xigg==
X-Gm-Message-State: APjAAAWnNkUi4a0f+WunFqWp2bQxZHX17PKXt6slm/NrP/aJbdIusj4r
	5XMHDih4FCERO5GWZpMJxTetFIpOAnEJSE0DK1xhe6WzyZ/L1qoSg8Cxwau/718RI3z8Pj8y19y
	XP4P9DwJAah6AhiZ9CtzqRsFjnVKurMY2VPSH26/E0nCfudhU7s+7Y65clTSbvX8jMg==
X-Received: by 2002:ab0:5973:: with SMTP id o48mr25024906uad.19.1560790669748;
        Mon, 17 Jun 2019 09:57:49 -0700 (PDT)
X-Received: by 2002:ab0:5973:: with SMTP id o48mr25024878uad.19.1560790669173;
        Mon, 17 Jun 2019 09:57:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560790669; cv=none;
        d=google.com; s=arc-20160816;
        b=JiPdiaEWlIgeoz9ByIXbxT4s1goIzpbrcdhYI2/KUYHj0LOudCexkaeedF21oP+uid
         n5OM3iI2i5su5B/8w8inQyg+ji36yH2L4R9qYdsXPuBdT7giLVy5Sa2AAaIyd+9leJfz
         bD6qYUrGQ/EvEqxK8sp7viTejvwd+w2r/HASRm5R6ARJta7nhI5eLolnmataRBSHChR1
         4ugMP41HJ4dk6q27KHfS92JmtKXe7l0Q525pIQEuMcoMCnhPQ6mU7uaUx3FchpCDdnP5
         N2FujC46TERosaXRRAUwKEZdtEbw4Zu2ztvD3F5OLoNu0SAioo39dOk0CDVivmR6d7ky
         QSPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=retltkRYeaxJ6adF3YGzOCqdGSJ+TnMcYlKByHm/5DU=;
        b=sqc/Aq6cHuJNMojk5tbQMszWCYd4z1bT5GIDvRXTHdOSZUp73i1ZHX4gp1JIeAqH8H
         b3b9B/iBvY18s0UHjor9X6SnLYoiMXrHEM1nV5w2SVX9CIJgFXUIPbrLwoMdEePkQDwc
         ewA9au45yY5ScKyk70hIpZUh5D0L6aSzBfcsbFRkjMVSD3RE8xkhpR/DDkiLhTPacM9s
         pva0vKMqRWtdHQvnNnGM7ozrKyB8ozp1UozEcHo/wmpXF8Y3I3JTVkJpU/SsJ4UErgsc
         WCm8dTANSftF8ohi/kUsmdJ8ciyVXdr2qNw2Zdpt/wKyL+6JaCN9xCrW5Iq0wjVijsTB
         DASw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HM9XZcRH;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k29sor5333945vsj.27.2019.06.17.09.57.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 09:57:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HM9XZcRH;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=retltkRYeaxJ6adF3YGzOCqdGSJ+TnMcYlKByHm/5DU=;
        b=HM9XZcRH7jNoUwKtDn/wkkMYYyg9wr6zjYQcvYAYvWF5M1tzrgs41DdFiwwTgvt1O5
         KjOS0GHXaKxXHbuqb3yaHFY6s5m+GgG8jbRV5AKURRu+BUwOFgp4r3kAue00v9koQG1w
         A3M5l+cF/ibNvE8yJCY4E6+A4Wcv9UTKgrtukbJgSFBngoBXKyC/nUsbJSqEshzxgU7v
         OjkzG8cTM1db0z9+CHPRCzJf6yJOwQUirXZIKRWYCQ5D1XOdgX6CDWUq7ZrKtG2PzpGN
         +3DiSEl9lQXDncbHpzuwreL+mokGyGGK7aL+x6DR/HBeGpJarIMjtc91XuMaEVI3t0qt
         MUIA==
X-Google-Smtp-Source: APXvYqzrhGSVJ7DV/F7d51q9N5ZE/3Gdj+PUpdVhrLQtXpA774FgTPlA9JMz0E4zBMsomoYTx9It+Pl+lwBwRCw5EpI=
X-Received: by 2002:a67:de99:: with SMTP id r25mr60881073vsk.215.1560790668543;
 Mon, 17 Jun 2019 09:57:48 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com> <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <20190617135636.GC1367@arrakis.emea.arm.com>
In-Reply-To: <20190617135636.GC1367@arrakis.emea.arm.com>
From: Evgenii Stepanov <eugenis@google.com>
Date: Mon, 17 Jun 2019 09:57:36 -0700
Message-ID: <CAFKCwrjJ+0ijNKa3ioOP7xa91QmZU0NhkO=tNC-Q_ThC69vTug@mail.gmail.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control the
 tagged user addresses ABI
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 6:56 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> > From: Catalin Marinas <catalin.marinas@arm.com>
> >
> > It is not desirable to relax the ABI to allow tagged user addresses into
> > the kernel indiscriminately. This patch introduces a prctl() interface
> > for enabling or disabling the tagged ABI with a global sysctl control
> > for preventing applications from enabling the relaxed ABI (meant for
> > testing user-space prctl() return error checking without reconfiguring
> > the kernel). The ABI properties are inherited by threads of the same
> > application and fork()'ed children but cleared on execve().
> >
> > The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> > MTE-specific settings like imprecise vs precise exceptions.
> >
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
>
> A question for the user-space folk: if an application opts in to this
> ABI, would you want the sigcontext.fault_address and/or siginfo.si_addr
> to contain the tag? We currently clear it early in the arm64 entry.S but
> we could find a way to pass it down if needed.

For HWASan this would not be useful because we instrument memory
accesses with explicit checks anyway. For MTE, on the other hand, it
would be very convenient to know the fault address tag without
disassembling the code.

