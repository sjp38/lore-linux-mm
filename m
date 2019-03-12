Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2D48C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:14:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9312520842
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:14:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="IHy3W6de"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9312520842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2419D8E0003; Mon, 11 Mar 2019 23:14:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D4D58E0002; Mon, 11 Mar 2019 23:14:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08F828E0003; Mon, 11 Mar 2019 23:14:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id C27BB8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:14:07 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 31so516432ota.8
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:14:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7qWivrke1+JwuU7zvcFQdEBmYHHYCsO9zAVfk3gSSCA=;
        b=fkWIzZUhZ7Sr+aCIfWDQu/rsORXS0e+GwKy3ryqPOT0eAfDsubMRFimsXMvup2jWv4
         in0odQZ3uxmg/PhxudVZv1V7in1hN7DB0YmqEg4QsLzHPFR8RjKx3qdhSri2wFy0sLdN
         rxdZib9nmuqMJRDgj12jugmTKgA+eGur/RonQCOchLDKeW13r/ahfwr4xiOwzBpavq9u
         Lpvlw/vylcyCMV4nf7hZ0CWRgBClcACp5zye8vAqoBJ+4JnBqSqiNujTg/SH+v2qVBAU
         XqW+T/FUdyUd5T4Eb0nnL0xeR9hRXzkQPVdXXvhQv4YGE92M2vSh8Hi4EC7x8jrfnDbZ
         zreA==
X-Gm-Message-State: APjAAAVoqcDUxfex2hKi1/DQTST1ECQvE7AfOUVCrOXFU2zlKiwEsJTe
	dcqXoPhpFVQyEA7C2NtCpKNcmxJRFFM7WVRwJNFNc5u9SFnJEyNFOPQK3/iVB7vKE5JFsaQ/qGJ
	gadBLYjQYYxGjdgiHrSyMJUcW73VQjlGKZTX82bG9AoKCtl+hcoLLc4gilmkkpkusew==
X-Received: by 2002:aca:4e06:: with SMTP id c6mr349369oib.71.1552360447250;
        Mon, 11 Mar 2019 20:14:07 -0700 (PDT)
X-Received: by 2002:aca:4e06:: with SMTP id c6mr349334oib.71.1552360446160;
        Mon, 11 Mar 2019 20:14:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552360446; cv=none;
        d=google.com; s=arc-20160816;
        b=L8VblgcAopIVv7B8vwiuVk/P0Wlv2kkLRzI98JP7bAHt61fEHhtnIVWiVlfdc1Uz0G
         8x0t3al7vcnhSAG99DLsAW635F0vrkYleziDXvSfCDrXteQyURVTN9SbUfu5yG2ZC7uX
         OHmy/ppDV5f2REc5FSHtQhX7cwzTyxmYmkxYyp9Z2IEhpFdIsZPa7n0rhxrKqL4oodht
         dAGrst7Hv+ArS3i8SwFc3qAeukXU7ULpzknhakAg+6kp5zFLRkwhSdYQsLcRofPtExCT
         kMGBUu3pnzBmK2k6IS+SKjsbYRy+lQBhvvhwArGTGSYvMS8iEp/a9piEW2pC9KdaAfOi
         VUuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7qWivrke1+JwuU7zvcFQdEBmYHHYCsO9zAVfk3gSSCA=;
        b=yO05zu4MQUVC7bT26/2Ts0VW7HXPfIcEcEnCFDpNsNj7zfYUyEjpB+XayO0Ra2oCV0
         3o57ih7aFxhPu2WCekXWrBQntHh+fTF5SW67Nt7qCjWKRntjR0BINHImbax4e5ZTRiGd
         IrCL+zOIp8u1Ncd4B8Lft3ij+dauOpBmARTMBO/23KTyxpITkQ6Ra7JInH1iGDvwAay5
         elFtcgkIlPq8M/fRUkywClocTxyP6wqGtCUGa8T4Z1a8LBvu9MMP9VJuXElbbmuRgYU3
         Scvj4b6qHp2Fi8Y8RuuVoXQCZ36zXx1GePyhjnUxM8lIw0Y6VZiK3z8c/nBYCK7zzVD6
         psDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=IHy3W6de;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4sor4423333otk.41.2019.03.11.20.14.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 20:14:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=IHy3W6de;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7qWivrke1+JwuU7zvcFQdEBmYHHYCsO9zAVfk3gSSCA=;
        b=IHy3W6defCeVWZYQh+mwDXXzgdoiGiM9ZPoxi+t0V6RSb0enrLdUrdrsH/+cO0ESRu
         pow8hTXrUvTPY8ub4I4WILV6GPWncs5UZzWThq+KRoKQ6Wt6hlt6arK9n/dAymH879rx
         hgaVO9mHgNWfkJF7KTN7GjKu2+TBOtoYCbfx771O3bWwVxLs//2roMuT0mR2H0ebOApT
         85GY04wPz8g7iJ56ZOiRKa1tgWhrhsjGsqodolkig6DErig6fWBFjoDXNG5OiffLJ2/x
         WTlq47eDLuPvi6OOHPk7Ov/aYtAM2McbCP+xrE170rKhbrHq39nbCt8F4tg32TYLjMJW
         Zm0g==
X-Google-Smtp-Source: APXvYqzq2BNXr3IOMOHqX1ihZacbvqShg/WC5JuoL3Q3eN+1qDMtXiRWdE3qmeU0IrrnbFpKX+nxlWm9FiUKY6nJuxs=
X-Received: by 2002:a05:6830:1c1:: with SMTP id r1mr22402830ota.229.1552360444860;
 Mon, 11 Mar 2019 20:14:04 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com> <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com> <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com> <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
 <20190307094654.35391e0066396b204d133927@linux-foundation.org> <20190307185623.GD3835@redhat.com>
In-Reply-To: <20190307185623.GD3835@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Mar 2019 20:13:53 -0700
Message-ID: <CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 7, 2019 at 10:56 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Thu, Mar 07, 2019 at 09:46:54AM -0800, Andrew Morton wrote:
> > On Tue, 5 Mar 2019 20:20:10 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > > My hesitation would be drastically reduced if there was a plan to
> > > avoid dangling unconsumed symbols and functionality. Specifically one
> > > or more of the following suggestions:
> > >
> > > * EXPORT_SYMBOL_GPL on all exports to avoid a growing liability
> > > surface for out-of-tree consumers to come grumble at us when we
> > > continue to refactor the kernel as we are wont to do.
> >
> > The existing patches use EXPORT_SYMBOL() so that's a sticking point.
> > Jerome, what would happen is we made these EXPORT_SYMBOL_GPL()?
>
> So Dan argue that GPL export solve the problem of out of tree user and
> my personnal experience is that it does not. The GPU sub-system has tons
> of GPL drivers that are not upstream and we never felt that we were bound
> to support them in anyway. We always were very clear that if you are not
> upstream that you do not have any voice on changes we do.
>
> So my exeperience is that GPL does not help here. It is just about being
> clear and ignoring anyone who does not have an upstream driver ie we have
> free hands to update HMM in anyway as long as we keep supporting the
> upstream user.
>
> That being said if the GPL aspect is that much important to some then
> fine let switch all HMM symbol to GPL.

I should add that I would not be opposed to moving symbols to
non-GPL-only over time, but that should be based on our experience
with the stability and utility of the implementation. For brand new
symbols there's just no data to argue that we can / should keep the
interface stable, or that the interface exposes something fragile that
we'd rather not export at all. That experience gathering and thrash is
best constrained to upstream GPL-only drivers that are signing up to
participate in that maturation process.

So I think it is important from a practical perspective and is a lower
risk way to run this HMM experiment of "merge infrastructure way in
advance of an upstream user".

> > > * A commitment to consume newly exported symbols in the same merge
> > > window, or the following merge window. When that goal is missed revert
> > > the functionality until such time that it can be consumed, or
> > > otherwise abandoned.
> >
> > It sounds like we can tick this box.
>
> I wouldn't be too strick either, when adding something in release N
> the driver change in N+1 can miss N+1 because of bug or regression
> and be push to N+2.
>
> I think a better stance here is that if we do not get any sign-off
> on the feature from driver maintainer for which the feature is intended
> then we just do not merge.

Agree, no driver maintainer sign-off then no merge.

> If after few release we still can not get
> the driver to use it then we revert.

As long as it is made clear to the driver maintainer that they have
one cycle to consume it then we can have a conversation if it is too
early to merge the infrastructure. If no one has time to consume the
feature, why rush dead code into the kernel? Also, waiting 2 cycles
means the infrastructure that was hard to review without a user is now
even harder to review because any review momentum has been lost by the
time the user show up, so we're better off keeping them close together
in time.


> It just feels dumb to revert at N+1 just to get it back in N+2 as
> the driver bit get fix.

No, I think it just means the infrastructure went in too early if a
driver can't consume it in a development cycle. Lets revisit if it
becomes a problem in practice.

> > > * No new symbol exports and functionality while existing symbols go unconsumed.
> >
> > Unsure about this one?
>
> With nouveau upstream now everything is use. ODP will use some of the
> symbol too. PPC has patchset posted to use lot of HMM too. I have been
> working with other vendor that have patchset being work on to use HMM
> too.
>
> I have not done all those function just for the fun of it :) They do
> have real use and user. It took a longtime to get nouveau because of
> userspace we had a lot of catchup to do in mesa and llvm and we are
> still very rough there.

Sure, this one is less of a concern if we can stick to tighter
timelines between infrastructure and driver consumer merge.

