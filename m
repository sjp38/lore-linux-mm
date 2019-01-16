Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5F36C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 05:50:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C51220840
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 05:50:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="Cm8s3Ol6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C51220840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E42BF8E0005; Wed, 16 Jan 2019 00:50:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF1E98E0002; Wed, 16 Jan 2019 00:50:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D08198E0005; Wed, 16 Jan 2019 00:50:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 662118E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:50:08 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id z5-v6so1310159ljb.13
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:50:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VZ1+S4udBrUGqA2qKTo5GfQAEHGyi6IpM7GyhEi/87Q=;
        b=qjBHDBJmS0Fy4HT2wZrmUk1fx7712MTlz4+CCE0AFG3zWSLKkvoTKALOc6CgNzjsla
         EjyLAgzQ/axCwhawcWWkWY4osOd5fwlOkPeOWSxxchlCWK3EWNr6n2eWXxK+bjACiZgj
         /Pf8/654xOtzY7baxR8bHvG3uMr2uL4HfTvkqXwY2d6+/FsW0SQ/xi2lAPcfxFetLX2l
         Ymf8cu9W7/lGl87S/FTUGM0YubUNM7yt+gVsl2Mt91lRR63DxCv94NB9vKhzY7aOsOb1
         EekIS8edyXgnX3RInQaGwNGfrC1vQkypoLvtxyyOMIm/vC3snbrM2gSjpS7jHjbYtnbY
         aEsg==
X-Gm-Message-State: AJcUukejd2Q+VCZk3sXx5GwEiWrtAsSHPO1GSYFlfviJZeP0dXrYISIC
	OmAzy7oOtk6heWzfy0dQ4dnP44BN5Bdll2/9GGWKl6JEmMQUCvPxHLPpPV0Vxky9jcX4fcmIuCI
	0cBYd485/SBehQc9oE8ZV7qTHwgMx+eETJBhx1onkgGdIRV48RzcLO/vJRFdFfXSwoTv44PrlUY
	J1qRb1KILmcgGUpiQNntRU2KvgxBzwxDRzcys60m3lsxmJvqmTegAq7xQjIhbKbe/D/msGIc2QK
	KukGPxmhYaoRRubjQGHADj99mYln+B8A4VEG1SJt4ouOcDJ+dIWqLFanZyNJcBVcFnFAnGzUWMh
	0I7EfQcK2RO0BVvhPMHjoQVDTMdeVrICmlaHT+IsJW8Pe6IOLK7QnNI+dqPR58D7b33wLb8mRDa
	D
X-Received: by 2002:a2e:484:: with SMTP id a4-v6mr5274786ljf.27.1547617807766;
        Tue, 15 Jan 2019 21:50:07 -0800 (PST)
X-Received: by 2002:a2e:484:: with SMTP id a4-v6mr5274740ljf.27.1547617806799;
        Tue, 15 Jan 2019 21:50:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547617806; cv=none;
        d=google.com; s=arc-20160816;
        b=vzS8E3iHECH3PMF3QWaBiznkMB2gZ8gDYaxrLtKgXg72c2P1uLGJjCWqZjCnbf2OBL
         Afil+E+HP6VjKyPkPX15d8M6iPq9tePg7RUVPk4Zvf8Z3qo3eMLm1PigWG0oPVV6/K7R
         c8/KPKArJFF7HkHMZWK8ARZYyEjv4TGwJ9C3HxOFrVE2dwl4kJuj/Pyi5bSF67fH1PEf
         dmGCjvx9sTQbkEbeWt0dqPKhkxlyFM34af/oUXwtIEQs2NHJjzKrmG503rlHs9igN/Gu
         K8YfmdLuotio7toqBAG19hDJPJG7j6cFVsREAvXWeB9OCezdXS1QYcA51vTatXeS17yD
         H3cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VZ1+S4udBrUGqA2qKTo5GfQAEHGyi6IpM7GyhEi/87Q=;
        b=zUz2pUuDUNpM6pbyZIcGzDMedithMSdgM9hwEedEmFYINnbJCQ9KlCGP9LGIvhtXjF
         oGTZLamxTTfK0p5s0sVE5lxH/QizO0QUgMADsEfH8lfZ5e6knpJ/Y2O0D9Z+/jT2mQxC
         jCpJc5qWa5dMG2+8cckYOEBWrIqpuiZpFLmDzP+b30NnFb2xIbEh/ST483Eb9rEQ+pnM
         La9TcrVa49c3+h2fzaWhoXolv2sFbmBKaKIjOZIfi47EHalr4Sw3Im+kM96tzyTeTpBe
         m8Qzum06mCbYuOvmMNLRy5jOKAe37bgSNODgzcFxudcE+yaMZp4H+TgEziqdA/XISTl3
         d9/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Cm8s3Ol6;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor1790435lfe.49.2019.01.15.21.50.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 21:50:06 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Cm8s3Ol6;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VZ1+S4udBrUGqA2qKTo5GfQAEHGyi6IpM7GyhEi/87Q=;
        b=Cm8s3Ol69OXV+2VWR7fkXnsX1n+j4dzdhPWdlz+bQiLV2defpBkGRVFg2h3wehxX/B
         m22hjZI3XvFBpyA+dLrVT89Aow6fflPmxfHCQP4AbP8oZLi4pChb1R0mNyMz920VsOlR
         MEg/wP8hNUn4G/821olrUDpO5emm1o1mNr/E4=
X-Google-Smtp-Source: ALg8bN6e3n6flu0mxN2/sxjFoS7s0vg8UDSyZ7N4UD/X0jNgrFuwskiRl5s3sJCSpUiNZomnEt3vwQ==
X-Received: by 2002:a19:c70a:: with SMTP id x10mr5398306lff.88.1547617805365;
        Tue, 15 Jan 2019 21:50:05 -0800 (PST)
Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com. [209.85.167.45])
        by smtp.gmail.com with ESMTPSA id r69sm1014983lfi.15.2019.01.15.21.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 21:50:04 -0800 (PST)
Received: by mail-lf1-f45.google.com with SMTP id z13so3889877lfe.11
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:50:03 -0800 (PST)
X-Received: by 2002:a19:7006:: with SMTP id h6mr5627124lfc.147.1547617803433;
 Tue, 15 Jan 2019 21:50:03 -0800 (PST)
MIME-Version: 1.0
References: <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard> <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard> <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
 <20190111073606.GP27534@dastard> <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
 <20190115234510.GA6173@dastard> <CAHk-=wjc2inOae8+9-DK4jFK78-7ZpNR=TEyZg0Dj57SYwP-ng@mail.gmail.com>
In-Reply-To: <CAHk-=wjc2inOae8+9-DK4jFK78-7ZpNR=TEyZg0Dj57SYwP-ng@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Jan 2019 17:49:46 +1200
X-Gmail-Original-Message-ID: <CAHk-=wje=2Pndo+xZ5fLJ9VCoo6NYLV_a9D8mxpuSTFdz3eGMg@mail.gmail.com>
Message-ID:
 <CAHk-=wje=2Pndo+xZ5fLJ9VCoo6NYLV_a9D8mxpuSTFdz3eGMg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dave Chinner <david@fromorbit.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116054946.CqBXLcVr9jwYVavTUGRBROg-glGpvs7rzl_iK6FScxo@z>

On Wed, Jan 16, 2019 at 4:54 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Wed, Jan 16, 2019 at 11:45 AM Dave Chinner <david@fromorbit.com> wrote:
> >
> > I'm assuming that you can invalidate the page cache reliably by a
> > means that does not repeated require probing to detect invalidation
> > has occurred. I've mentioned one method in this discussion
> > already...
>
> Yes. And it was made clear to you that it was a bug in xfs dio and
> what the right thing to do was.

Side note: I actually think we *do* the right thing. Even for xfs. I
couldn't find the alleged place that invalidates the page cache on dio
reads.

The *generic* dio code only does it for writes (which is correct and
fine). And maybe xfs has some extra invalidation, but I don't see it.

So I actually hope your "you can use direct-io read to do directed
invalidating of the page cache" isn't true. I admittedly did *not* try
to delve very deeply into it, but the invalidates I found looked
correct. The generic code does it for writes, and at least ext4 does
the "writeback and wait" for reads.

There *does* seem to be a 'invalidate_inode_pages2_range()' call in
iomap_dio_rw(). That has a *comment* that says it only is for writes,
but it looks to me like it would trigger for reads too.

Just a plain bug/oversight? Or me misreading things.

So yes, maybe xfs does that "invalidate on read", but it really seems
to be just a bug. If the xfs people insist on keeping the bug, fine
(looks like gfs2 and xfs are the only users), but it seems kind of
sad.

             Linus

