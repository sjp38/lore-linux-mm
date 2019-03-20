Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86560C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:21:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39758217F5
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:21:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="bzw2JUtt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39758217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF8896B0003; Tue, 19 Mar 2019 20:21:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA7F06B0006; Tue, 19 Mar 2019 20:21:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBEEC6B0007; Tue, 19 Mar 2019 20:21:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92ABC6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:21:01 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id y6so19469701qke.1
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:21:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zQmCD3sREUOQwH4FPp6CA4aVK08SIwr97WyKhXdZnQg=;
        b=ay/Bao3w33a1NBHtt/TXkAcUw7FLE0eqftAsqXw2T1UPx6uRgpsn72o3kaVKy7DFQq
         oTl2SGrEAuUXDiRpsTIt2bWQadDPxsSdVuIdYnPAWqIlp0a2Ml2dMsn0gQvBWxl4Xmf1
         MIIBpqcGHytazpKwRZD0cjzztSSD/dj+pjltqdwOIkftf05bXj69GUpXYWEJJvDHEXC4
         QfeZVSqwcBQXnBoCexeO8hAPAlim6tvfWo7XJnV+Ty6iy4tfZ3eQJCMMPb3bNQrw2zZG
         RqUJZyXrYtWLxqdhwUOrHZ2CJ2N1v5kDSyblyQ4Dfh+nizYGz5MbxsTgjqkuQshJzB0/
         CrBg==
X-Gm-Message-State: APjAAAXFe7sINl4/ZJD0gDcL6K1liGqy25HL62ClrKC0351xi4PP35S+
	0qKOfDt8T+o9mldRwnxcF7OMqC7BRJLAsXPw8aeHXqYJfVGoKGF6JGCVYLiu1+8fpXnSwRCLk1b
	LQVKDntsWav6rUQ7IUeZPHz0WKqpOyV7lEi9M0q04yY0dk9KwCDRN+s22OEy9jT2UFQ==
X-Received: by 2002:a37:cfc3:: with SMTP id v64mr4277107qkl.144.1553041261315;
        Tue, 19 Mar 2019 17:21:01 -0700 (PDT)
X-Received: by 2002:a37:cfc3:: with SMTP id v64mr4277010qkl.144.1553041259134;
        Tue, 19 Mar 2019 17:20:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553041259; cv=none;
        d=google.com; s=arc-20160816;
        b=YHPwG4+cyKZTlyyN70RaUpLxO9/QzI53rTILRa6W3sR8T9zcfH/UP22DpREij7Ux/w
         NOYvcF91qGtdpsbG2qNyS67gvVg33Yb66gh547Cm6OfnjHRzQK3LDXAUuMOQat1B05uf
         hRLpOIGjs522fmxlOuoe1w5NIH4CiINQR+Yz5NNAUCCU1yHIgESlyCHIspIv1nxbI0V4
         j89XUsD9CF+5U1vp66Cvv1c3gaUH9IsVtirEtAub88XyH83VDR+vSPcmW24XOGS+u4XR
         Qdp0hweD5ELS5h5aqQC6nOSKKoXr6eBfIsfbNLGLGGaBs9S6XLG+Pvy8MB38YQ/Gk9qO
         aovQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zQmCD3sREUOQwH4FPp6CA4aVK08SIwr97WyKhXdZnQg=;
        b=oqLzrcPJL00TaGj0LeExRW5+lntt4+NTXwdDsfJQFqplhJ0g7304T2Lh4g6CAa8CV4
         siRHuhMPtB4q/tdAZYd8zPMmoXkdJVD1nUvILk/6YWmRDVutGaBhKKfHcCzFa+RYnN3M
         l0LW7jPQz1Pm6+tYOOa3gid6s9kPI9rBhRZbs6gor7QKUKTR18MkQ2OIWcrb/mvBbeKT
         p0PpSvL1/Ycfd3BficZj0kbMWnHWMrU0GcjBqbxLsgSRX2S77CopmetibjSP5i3XuhBB
         YoQVh+YSwV+tVy//6d4MYsjzNq4Aud6dh9v9stKGaFT4UIuNDUYffRH0QehNooBDIqLk
         Px4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=bzw2JUtt;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b3sor923257qtg.35.2019.03.19.17.20.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 17:20:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=bzw2JUtt;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zQmCD3sREUOQwH4FPp6CA4aVK08SIwr97WyKhXdZnQg=;
        b=bzw2JUttAidp/yj9zNb21J2mklrB4ORgex6qHvNV60XXoeRTiL2ESkymUJXXScOhHW
         6UfHgZ7wAsXNBOIuWhTM4mjapWTuMJZThYvwqBXaDegUjzFo2hRQvQ7yBG3F8zjRC3lf
         B0uRPP1X7i1Fm7+CpAmtBJ1sVvvD0DbnZr1oo=
X-Google-Smtp-Source: APXvYqxe7hcm85vJxzxb+3t+Kp2FxLDCiQS1m2UbUsHfl7Y/EfaBLiyfZcg8Qx2I3W4SsvM+/rsaTGK1MvV+z0Qwo2Q=
X-Received: by 2002:ac8:1884:: with SMTP id s4mr4584119qtj.339.1553041258782;
 Tue, 19 Mar 2019 17:20:58 -0700 (PDT)
MIME-Version: 1.0
References: <20181210011504.122604-1-drinkcat@chromium.org>
 <CANMq1KAmFKpcxi49wJyfP4N01A80B2d-2RGY2Wrwg0BvaFxAxg@mail.gmail.com>
 <20190111102155.in5rctq5krs4ewfi@8bytes.org> <CANMq1KCq7wEYXKLZGCZczZ_yQrmK=MkHbUXESKhHnx5G_CMNVg@mail.gmail.com>
 <789fb2e6-0d80-b6de-adf3-57180a50ec3e@suse.cz> <CANMq1KCfhWdWtXP_PRd_LEEcWV8SQg=hOy4V7_grqtL873uUCg@mail.gmail.com>
 <CANMq1KBKF9aRj+8t+AQusNLOF5jrHJ4qY5C00AKXkO6e-8wKuQ@mail.gmail.com> <20190319105637.4949b00b854e955d61c0359d@linux-foundation.org>
In-Reply-To: <20190319105637.4949b00b854e955d61c0359d@linux-foundation.org>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Wed, 20 Mar 2019 08:20:47 +0800
Message-ID: <CANMq1KAWbfNJQt=RaK-+us7eS6ReLFqaEbO3hMPfBy_w3ukj7A@mail.gmail.com>
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

On Wed, Mar 20, 2019 at 1:56 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 19 Mar 2019 15:41:43 +0800 Nicolas Boichat <drinkcat@chromium.org> wrote:
>
> > On Mon, Feb 25, 2019 at 8:23 AM Nicolas Boichat <drinkcat@chromium.org> wrote:
> > >
> > > On Thu, Feb 14, 2019 at 1:12 AM Vlastimil Babka <vbabka@suse.cz> wrote:
> > > >
> > > > On 1/22/19 11:51 PM, Nicolas Boichat wrote:
> > > > > Hi Andrew,
> > > > >
> > > > > On Fri, Jan 11, 2019 at 6:21 PM Joerg Roedel <joro@8bytes.org> wrote:
> > > > >>
> > > > >> On Wed, Jan 02, 2019 at 01:51:45PM +0800, Nicolas Boichat wrote:
> > > > >> > Does anyone have any further comment on this series? If not, which
> > > > >> > maintainer is going to pick this up? I assume Andrew Morton?
> > > > >>
> > > > >> Probably, yes. I don't like to carry the mm-changes in iommu-tree, so
> > > > >> this should go through mm.
> > > > >
> > > > > Gentle ping on this series, it seems like it's better if it goes
> > > > > through your tree.
> > > > >
> > > > > Series still applies cleanly on linux-next, but I'm happy to resend if
> > > > > that helps.
> > > >
> > > > Ping, Andrew?
> > >
> > > Another gentle ping, I still don't see these patches in mmot[ms]. Thanks.
> >
> > Andrew: AFAICT this still applies cleanly on linux-next/master, so I
> > don't plan to resend... is there any other issues with this series?
> >
> > This is a regression, so it'd be nice to have it fixed in mainline, eventually.
>
> Sorry, seeing "iommu" and "arm" made these escape my gimlet eye.

Thanks for picking them up!

> I'm only seeing acks on [1/3].  What's the review status of [2/3] and [3/3]?

Replied on the notification, [2/3] had a Ack, [3/3] is somewhat controversial.

