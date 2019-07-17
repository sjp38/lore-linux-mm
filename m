Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78288C76196
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:43:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 336C821743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:43:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dPqGbc0m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 336C821743
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B882F6B0006; Wed, 17 Jul 2019 07:43:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3AFD6B0008; Wed, 17 Jul 2019 07:43:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A295A8E0001; Wed, 17 Jul 2019 07:43:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4B46B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:43:04 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so14319525pfw.16
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:43:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Grx9Ph9cpPxnp5U6FBRGOs65Gt1iaoMhcGq5W71SZXw=;
        b=Th1pn90WaRTcZwGZyrOTuPgC6IL/bdztB7nPhAeuL2pdTsQKH7HaCaPLCF/rIngTnq
         Koes7qwF5C4mKuYkoQjQfZhLzyeWk9/xbJXi1+K5PIeN+PpsT3h1bZ9UbTLYJjvWMV/n
         OuTtMNT0rA41t9wMYJOZgxX0oyewg65w1Fkmv5TwCYai7P5RaWDm2NNSWFDkPRlQdPxR
         JIdNxjSYOATq1Bbd892smQJ++QNClrzDwRmoriubvtfmV4Udvf72pBhdtv/SHeNdx02B
         8IRnQsAkJe4Dsu5PDTF69YjKnJdIKW/lFjEjiwIrtuYGKFkqsItJn8syqABR5PQzymWi
         aWhQ==
X-Gm-Message-State: APjAAAUBWjYLrxZqFelVaX8j+IWwiFHEgtcxE7Jz70FpMRzjavdfP3An
	ot25egH/F9ZctP77vAuPLpIamDwJUa176ax16LX/muvLBbvKOGYOAnJIpwlMq3F27ftLD3RylVL
	Yk+0ewIX7jtw3oWsdsK5b9ak+MVrhiZjZ+x3CHowQ0N1bzjbwDrs1KxPwFBvX6I1Oww==
X-Received: by 2002:a17:902:7c05:: with SMTP id x5mr42901149pll.321.1563363784054;
        Wed, 17 Jul 2019 04:43:04 -0700 (PDT)
X-Received: by 2002:a17:902:7c05:: with SMTP id x5mr42901049pll.321.1563363782755;
        Wed, 17 Jul 2019 04:43:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563363782; cv=none;
        d=google.com; s=arc-20160816;
        b=sl7KXG45eGbcJOt8DXsCVIpNpVkme8eTJiLEaowhzG/QorJOnILx95L0as4ZD71iVx
         X2hWilTXhyPY6R1g0mhl9DztPnYr+46QbSKJuKu0SEnnXNTZRXhVjZSdJqhxc9tKek/r
         OWeIJ/Jb12H2MJDBYHvKiXSoIySApjMnQnqpJQOmxYmwj2L9d8Tg68Gs8abZLD/YO+o9
         YbifzvTyIO6tGGSMxqMRPhlYIbtqYu0J6DBK25E3+jZrmWEV7VafJKffh+zVh+7MI5Db
         tpx8oT2KthcQLFiS0qPkqoPl7Monvi7oyoMnOHRUSG6bg0YZLk/rQ+Q9S+78G/Cie+Bp
         eDjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Grx9Ph9cpPxnp5U6FBRGOs65Gt1iaoMhcGq5W71SZXw=;
        b=P3qhIauFn3TviM+g9QULrvlh2ZBZlRP0wkHp/dJ0R7Sxo/7gqtWNKjCKH69pMC7p2X
         HMfDH/rdUGVEn1Cgu4mAvXDmvx9rfUpbNiRuB5MgR312ysoCrKIUuEe7uE1sHu18Fjrq
         nney8I3s1Q7HW49VDlRk3gk5FTY23XlrpF7x70GDJFowJU9eyvenkpJ9EqsRG/Vad3F6
         TCoXVkF0Wnw9/WCJ2JV8/BNXdJxpu3ZYCg8qwuTaF9kumwuQKMfC0IOR48rF+1pVPUCx
         NS2UYQ6Wt6j4PHjoEJqVKLJYgRQxHQHCc8hv/0upuaiqilbFFpi3Dzk78xatmr443e2s
         PEKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dPqGbc0m;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor28921427pln.13.2019.07.17.04.43.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 04:43:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dPqGbc0m;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Grx9Ph9cpPxnp5U6FBRGOs65Gt1iaoMhcGq5W71SZXw=;
        b=dPqGbc0mQ4L1HVZkSH8ToVI8fJKg/9UNHDO/j/ERbXAicYMzOFznsbpKlaHUysv6li
         HI+ov6aZkI81aTTtxCqQqgB/bUVOpQn9oyTV62JlPhH7/hgOpXEwCdWu9ddqQHOpZpdv
         vvSbjVE/k6KiaC4iA854H6gt6BntwHIeZhW6TlwY6wZ/6+elD6DGPCHZxZrxLz2uCTHc
         8iFhpa9H1Y4EYvcxgufIOEc+0j2fY1DuwRMYeLwfiF/zvSCA0YG2Xctd4B7QhffRyXW7
         79B+/AUSAWe5ZZuaO+yAHuZlFSQxsBpNhxsDDOkk9SiW6k2AqHelqnkNry2oBYROn4ta
         qk0g==
X-Google-Smtp-Source: APXvYqwmLG+YoWbUJiFaN+0PkmRQxPro9175aUMwlEodu495a+iL+q6DhBuBElFNfaLl03HSknMS7Mny75X+YTtbitI=
X-Received: by 2002:a17:902:8689:: with SMTP id g9mr39719354plo.252.1563363782037;
 Wed, 17 Jul 2019 04:43:02 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com> <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
 <20190624174015.GL29120@arrakis.emea.arm.com> <CAAeHK+y8vE=G_odK6KH=H064nSQcVgkQkNwb2zQD9swXxKSyUQ@mail.gmail.com>
 <20190715180510.GC4970@ziepe.ca> <CAAeHK+xPQqJP7p_JFxc4jrx9k7N0TpBWEuB8Px7XHvrfDU1_gw@mail.gmail.com>
 <20190716120624.GA29727@ziepe.ca>
In-Reply-To: <20190716120624.GA29727@ziepe.ca>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 17 Jul 2019 13:42:50 +0200
Message-ID: <CAAeHK+xGfCSNgJ1FA1Bi3-6iVZNa5-cPJF54SY9rETqSqnrOTw@mail.gmail.com>
Subject: Re: [PATCH v18 11/15] IB/mlx4: untag user pointers in mlx4_get_umem_mr
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
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
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 2:06 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Tue, Jul 16, 2019 at 12:42:07PM +0200, Andrey Konovalov wrote:
> > On Mon, Jul 15, 2019 at 8:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > >
> > > On Mon, Jul 15, 2019 at 06:01:29PM +0200, Andrey Konovalov wrote:
> > > > On Mon, Jun 24, 2019 at 7:40 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > > >
> > > > > On Mon, Jun 24, 2019 at 04:32:56PM +0200, Andrey Konovalov wrote:
> > > > > > This patch is a part of a series that extends kernel ABI to allow to pass
> > > > > > tagged user pointers (with the top byte set to something else other than
> > > > > > 0x00) as syscall arguments.
> > > > > >
> > > > > > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > > > > > only by done with untagged pointers.
> > > > > >
> > > > > > Untag user pointers in this function.
> > > > > >
> > > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > > >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> > > > > >  1 file changed, 4 insertions(+), 3 deletions(-)
> > > > >
> > > > > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > > > >
> > > > > This patch also needs an ack from the infiniband maintainers (Jason).
> > > >
> > > > Hi Jason,
> > > >
> > > > Could you take a look and give your acked-by?
> > >
> > > Oh, I think I did this a long time ago. Still looks OK.
> >
> > Hm, maybe that was we who lost it. Thanks!
> >
> > > You will send it?
> >
> > I will resend the patchset once the merge window is closed, if that's
> > what you mean.
>
> No.. I mean who send it to Linus's tree? ie do you want me to take
> this patch into rdma?
>
> Jason

