Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FB14C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:44:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 292B6217F9
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:44:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YNTzEvLo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 292B6217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9A0D6B0008; Wed, 17 Jul 2019 07:44:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C49D28E0001; Wed, 17 Jul 2019 07:44:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B125C6B000C; Wed, 17 Jul 2019 07:44:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1136B0008
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:44:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g18so11914639plj.19
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:44:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=s96tbUHAJa/3W+S33QuecksVNxzPE4B+rwrtGBTPIRg=;
        b=HmisIK8u453Op3q2hskdxfj5FNeC7g89OxSNshcYbjMITWx0iUT+1zMUu2nU3IdhUv
         woLYRXZtmN7CHAhmwiQv0S1OVLNdlclVqB2LIvFI6d1Y0oqtR+0BNmk6/+SsneTz4XkD
         Ptv7SYUgwbvky0tip6fgSn6EMAGEcQq04C8tL0NC5OUHMI8QQgpjWj5383kLp3ohkPy6
         vN00xnNV/qTN801p7J62i6f4C7mE/+I4vAHRySFh7iMZkTnH1KVZrpi6IYLttDPni73F
         yGi4NiB+vGb0agKIbuUewWDSH/yV8u80k5d21I3u6nbXWlNSm34EcRkIdDDoUbmIlOdK
         0/oQ==
X-Gm-Message-State: APjAAAVGTOO2AjiriJkKnu/KZ6Ota2ELjb2OY37I/m4tLu+DyuwK5ELc
	Bp2R0uDDApwop3BdSXHD9cM9SpTj9xT8mVUIFT8bnJ9Uc0oL2X8MtTAcK92qad9pFoQWczOWgSp
	DHyF46ZLFeNbRp+bzZCwSfbCA2Rb2UjAer3aPJ+22hXT94O9mr2KGZCRNUp/0tU4b8g==
X-Received: by 2002:a17:90a:a404:: with SMTP id y4mr44918419pjp.58.1563363860060;
        Wed, 17 Jul 2019 04:44:20 -0700 (PDT)
X-Received: by 2002:a17:90a:a404:: with SMTP id y4mr44918359pjp.58.1563363859058;
        Wed, 17 Jul 2019 04:44:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563363859; cv=none;
        d=google.com; s=arc-20160816;
        b=SCiPxZvn3CJvBS4OjqkCfcHqjUM13HfkgYRCh8J8QsgN49XU+MdGp1P4JNIV1cEOvD
         bad9S3KQc9RYQRQGPzoyH4rE7qmodrwGl77QCNvOUn2EYGdgnnFmnYhmhG/O4soGvc74
         8el+fJ7TF4J1lhDfnPrSdEfeDsLLXtzHnCyFYOg8/Kj7LiOIF79R0LU1TOhUxzRq+o+H
         o7tny0mrgX2WonRh6VD4Fpimc+aX+nTUXhWnvG8oS+y8qhkWelJaE+Qr9WQni7D/b9Or
         SIYq8MzICxk7DOEHtEmuXAYZN0Pk69hMTqYIEriGQL8ODioHOtZZ4l7IdjbcMGJNR7Yl
         u9mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=s96tbUHAJa/3W+S33QuecksVNxzPE4B+rwrtGBTPIRg=;
        b=bt1Cm7NGkvLANRvba+020Cu82g5vGb7EmH2wIjTTZqH2K6UXP+wWN79BZm1h0qu/ja
         usV3wRYNO7RJjJwrEin184/0Tcb1nV07LuR1LxJnBYPz4H7fGj96+waFuHrpakuwtzno
         kQh3HSxsFNLWRs2al4c9m4WrjbbLaVbB35alKjAlpwvbM2GOAUhkrU6mmMrF6f5tT4K0
         M4BSk43TVa3Uwf7psdOpTvgxK7ASqsFSozaKJlXTrPd3HlxOi8ztv6rSmhyPW154rvtz
         1/d5gyoqACKNUswjCBwcY3LijNkCkefKJ20CuPe9NKzpRDM954ehgNCgEe4J7NJLMif5
         3ZgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YNTzEvLo;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w11sor12383937pfi.56.2019.07.17.04.44.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 04:44:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YNTzEvLo;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=s96tbUHAJa/3W+S33QuecksVNxzPE4B+rwrtGBTPIRg=;
        b=YNTzEvLokDKfBiND0F2uTRtNbbscQoeYlRAIZ4D4gm+fPunaVpSxT9yFu1P0pJ6lio
         xWTqHSLTx3ZiQsVVIdfvcsAEZX+UwZ3GwnRk6z/9j+jj49uvH9o3OWPLDccY+IbVHGze
         VX/w7SlL3Vzx+t0xrwbctuweCHGIlBKbcd05Q0zBlUJIzL3VkiYxJwnzmtUL5R2SnxIl
         RhMYnRo7T8e4Wl/4YHx7n44SfOzOXvvpPCN5gZKipQVyiczav3qSb50tsdB3ZZ0CfrCh
         dofC27Pihb8FLt/R6YXAogt8ZfxAC6UrwAQzPlEU0+w5SGEaRflsRUqY/qTdnOsoVA2h
         liiA==
X-Google-Smtp-Source: APXvYqxCr99MNxoD8F3ipCKfGH5Ic+wArEB2kJiBZjN+Ft8BlSUogLYhlY5cWCf0y3NDyGKfQgFMQFiKtGoY4M7YZGQ=
X-Received: by 2002:a63:c442:: with SMTP id m2mr41068862pgg.286.1563363858315;
 Wed, 17 Jul 2019 04:44:18 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com> <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
 <20190624174015.GL29120@arrakis.emea.arm.com> <CAAeHK+y8vE=G_odK6KH=H064nSQcVgkQkNwb2zQD9swXxKSyUQ@mail.gmail.com>
 <20190715180510.GC4970@ziepe.ca> <CAAeHK+xPQqJP7p_JFxc4jrx9k7N0TpBWEuB8Px7XHvrfDU1_gw@mail.gmail.com>
 <20190716120624.GA29727@ziepe.ca>
In-Reply-To: <20190716120624.GA29727@ziepe.ca>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 17 Jul 2019 13:44:07 +0200
Message-ID: <CAAeHK+xPPQ9QjAksbfWG-Zmnawt-cdw9eO_6GVxjEYcaDGvaRA@mail.gmail.com>
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

I think the plan was to merge the whole series through the mm tree.
But I don't mind if you want to take this patch into your tree. It's
just that this patch doesn't make much sense without the rest of the
series.

>
> Jason

