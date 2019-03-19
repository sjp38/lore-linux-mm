Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA589C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 07:41:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B6862146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 07:41:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="f5okvv0Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B6862146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 166A96B0005; Tue, 19 Mar 2019 03:41:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EF676B0006; Tue, 19 Mar 2019 03:41:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFA2E6B0007; Tue, 19 Mar 2019 03:41:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9AFD6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 03:41:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l87so16896990qki.10
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 00:41:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AKuHIe0ez2D49edy2KdVchoqrAYgE3HPWmIWLCE09Ec=;
        b=S2iiFspk/SfhO7naewowhcfmolSA8I/0sjzM+SiSPbz+FT61RV/Bsm1jtj6nfYspZW
         p22C7t+j4n6ad82+iyyzY8OwrFLFmavPB+dYL9T7FN8czD5UtyBjvZ4gFLFEIgwg2UYc
         ESwC5Ce+LrTenFweOuA6WFcLnII0/8o9s3+MKg4IrmCIJgXfj9tv3q9+3EAAURdp9CoK
         yVJQ0LH2ChaaKPVxNJ/Zl6P6wOD+klBIVes/f6yEF67zNFclLHYPpn4m8lYDHo3XPwQi
         ASTJTar1QZO5Uj7w7xvFKW19NCigHk2Zfy2RinHBhANVxTSyJHYXp3hrAFlzGtstPmVy
         e+Vg==
X-Gm-Message-State: APjAAAX60G+DXLocj73bLau+oq2m0o/9ZafEo/jQUsbZ1QEaP32PDIlM
	D4g9f42MlSpfjYjHWibsnJ+LimTBEB3OddL95Mvl21INk7kgaN3nlPLOF81Oz2LzrKDEE+ZbujB
	UBYTbcxnbYDWwd+4xPDuVcSuDSYIn6ka0Ylt3QJ9xn/wzpPnLZySjn1wwVuImeeePmA==
X-Received: by 2002:a0c:9acc:: with SMTP id k12mr740009qvf.211.1552981316560;
        Tue, 19 Mar 2019 00:41:56 -0700 (PDT)
X-Received: by 2002:a0c:9acc:: with SMTP id k12mr739973qvf.211.1552981315512;
        Tue, 19 Mar 2019 00:41:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552981315; cv=none;
        d=google.com; s=arc-20160816;
        b=fo6JhgrkisV15zR7GtNY2m/3vPzISbu2N69cIdh7GczqAAFBPJbLWw2uiAzKIBgmRH
         OgXFzitHgTXrjrOhvD+bLBJIenLDwFynMUPvjc6nnexh+sjchGu0fb49ZZY63Znxk8dQ
         9nSPDnPUIONBqWANq2YRJ40/JLZ2QnE08C9GiDo2b/uXV/yl44FG3NSqSUCIW04l6rKJ
         IQrVLvAu03aV7GvCdN0TqQGoiMcZa4rqInhDlTpjpwRDwK0dtAafpzzG7pCeN0iHRhgK
         2940ZDYKSf+m+ytMLUP2AfJhbJRV8r6Iee5wRUeqQwNrpphknFbPBK9GdsUPMWlS7Z9W
         2S7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AKuHIe0ez2D49edy2KdVchoqrAYgE3HPWmIWLCE09Ec=;
        b=oa+Yb8rqv4c0X6Af8MzqSCx6VuNfYUS9Sck21CqAlwSzWPKZXGqdfAO2XwYgofboBH
         MXCke+DY/oU+HTH6FGTW4NcyOmtB+soRFnoZ+UzXrzrTHBGzNUN8C8aTy0Giork3ud6w
         pZy1Jr1yMV1YhQI64wv19ishz8L6Z7ow3v08KuTt0r4t0Y9x7PfxKG3EQvNLM7RUpMCF
         q22YUJVEFhDXi65h6RXQCcTnZuB3tfXXsNaHoVCQ30xXEVN9scwc2MO93l5lC+NKYMDG
         5x9b5w5t5AdRkMegJ0B6Nov/nwSbr0d/JnFWNTtMu/L8jcZ67iu7VPjsFjgIA8sVZ2mi
         i59w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=f5okvv0Y;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w14sor13093281qvi.17.2019.03.19.00.41.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 00:41:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=f5okvv0Y;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AKuHIe0ez2D49edy2KdVchoqrAYgE3HPWmIWLCE09Ec=;
        b=f5okvv0YSXxOiGUhQw4iUOiBvM7CzNsYObuRbwBbb5LZOQ22iMLJe/k0BWAt1X4JF+
         vJejcZXJLYJ7IKLJb0R1XafrsZfg4HbSbgSVVMjygdD/NM1WQiu0EI0zFNMZ6pEXQFxR
         O0XuP2fLYqaGOOVqUlpYfmFxEegaKF1d6aEtw=
X-Google-Smtp-Source: APXvYqyTzjT1x47abBKr7srSawj1xAGftoqEUHu5HMf3q6pGjpDjpfkE6S5BUwrjCQsPa7PeAuixzWkMplru36AMRRI=
X-Received: by 2002:a0c:9319:: with SMTP id d25mr706464qvd.99.1552981314960;
 Tue, 19 Mar 2019 00:41:54 -0700 (PDT)
MIME-Version: 1.0
References: <20181210011504.122604-1-drinkcat@chromium.org>
 <CANMq1KAmFKpcxi49wJyfP4N01A80B2d-2RGY2Wrwg0BvaFxAxg@mail.gmail.com>
 <20190111102155.in5rctq5krs4ewfi@8bytes.org> <CANMq1KCq7wEYXKLZGCZczZ_yQrmK=MkHbUXESKhHnx5G_CMNVg@mail.gmail.com>
 <789fb2e6-0d80-b6de-adf3-57180a50ec3e@suse.cz> <CANMq1KCfhWdWtXP_PRd_LEEcWV8SQg=hOy4V7_grqtL873uUCg@mail.gmail.com>
In-Reply-To: <CANMq1KCfhWdWtXP_PRd_LEEcWV8SQg=hOy4V7_grqtL873uUCg@mail.gmail.com>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Tue, 19 Mar 2019 15:41:43 +0800
Message-ID: <CANMq1KBKF9aRj+8t+AQusNLOF5jrHJ4qY5C00AKXkO6e-8wKuQ@mail.gmail.com>
Subject: Re: [PATCH v6 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will.deacon@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, 
	lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Tomasz Figa <tfiga@google.com>, Yingjoe Chen <yingjoe.chen@mediatek.com>, hch@infradead.org, 
	Matthew Wilcox <willy@infradead.org>, Hsin-Yi Wang <hsinyi@chromium.org>, stable@vger.kernel.org, 
	Joerg Roedel <joro@8bytes.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 8:23 AM Nicolas Boichat <drinkcat@chromium.org> wrote:
>
> On Thu, Feb 14, 2019 at 1:12 AM Vlastimil Babka <vbabka@suse.cz> wrote:
> >
> > On 1/22/19 11:51 PM, Nicolas Boichat wrote:
> > > Hi Andrew,
> > >
> > > On Fri, Jan 11, 2019 at 6:21 PM Joerg Roedel <joro@8bytes.org> wrote:
> > >>
> > >> On Wed, Jan 02, 2019 at 01:51:45PM +0800, Nicolas Boichat wrote:
> > >> > Does anyone have any further comment on this series? If not, which
> > >> > maintainer is going to pick this up? I assume Andrew Morton?
> > >>
> > >> Probably, yes. I don't like to carry the mm-changes in iommu-tree, so
> > >> this should go through mm.
> > >
> > > Gentle ping on this series, it seems like it's better if it goes
> > > through your tree.
> > >
> > > Series still applies cleanly on linux-next, but I'm happy to resend if
> > > that helps.
> >
> > Ping, Andrew?
>
> Another gentle ping, I still don't see these patches in mmot[ms]. Thanks.

Andrew: AFAICT this still applies cleanly on linux-next/master, so I
don't plan to resend... is there any other issues with this series?

This is a regression, so it'd be nice to have it fixed in mainline, eventually.

Thanks,

> > > Thanks!
> > >
> > >> Regards,
> > >>
> > >>         Joerg
> > >
> >

