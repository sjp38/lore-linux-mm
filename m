Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D24DDC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 19:18:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58A7F2133D
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 19:18:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="HA0ukVji"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58A7F2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9A196B0005; Mon, 18 Mar 2019 15:18:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A20996B0006; Mon, 18 Mar 2019 15:18:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C1A46B0007; Mon, 18 Mar 2019 15:18:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63CD66B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 15:18:53 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id n63so2161720ota.2
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:18:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HdcqDhfG82EUtvlrw0QZap1nbV6uDvfkm3HpJPlo97k=;
        b=qVX/5yFoZh8+vgeZASHt0uimkGh9ZaZWKFPTEIZ12eFRLR9wDLosbVMzygi+PSmWAw
         BtC21KTJk2Q+wBPHC6QZcekSyUnn73sb4p8LCAljR9p/qSM06PDEX2Hq5EcYXzbrfs4i
         MlLct0mPcM670BlSGEzUHX3DXS/rvO5X6fkKOwlKJJtA+xsezWkh0pNOA2S6ibzil35L
         /rYNfXkLUBLvFFNPQ9ayQA8G4nLh1s4TA9U6zjisxlNvD97GFAoNCjJGfzc3Av6ycSrb
         KOSb8Fx+byEEbXgLc/E1Je6vEpbxjO5rjZ5auzLxyj1bTj25Vx0+bXO47qJsHM5tuCDh
         e/JA==
X-Gm-Message-State: APjAAAUOPgw9ZfBRzpCTBzl47q3Q63RYoA64pi1esoLGX9IMHcvMM/2t
	3arUZB9yTp9AjogLzHABpEOgZtAV+0LmnbxVU4IHjpSZdeX66SVoUpgqC2jiHaFs02oj/dBNfGB
	GNxrpcSXlYEc1FzqNH1m3zLBd+ah7ULJCSgHv2pxgAEJwNijeChAYpmZ2lH0BkkExew==
X-Received: by 2002:aca:5dc6:: with SMTP id r189mr311281oib.132.1552936732807;
        Mon, 18 Mar 2019 12:18:52 -0700 (PDT)
X-Received: by 2002:aca:5dc6:: with SMTP id r189mr311222oib.132.1552936731720;
        Mon, 18 Mar 2019 12:18:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552936731; cv=none;
        d=google.com; s=arc-20160816;
        b=S4YmVDOHY5ia/pwfPti7r1wNxsfcEBdBtVPRXwHgLzLkr4EceSiianBRZ89ZoSvB9q
         x8lCGoKNd1axRzGjMpSdCxy38cPP03vnVruDNvKU6Pr76UR+N8F3kLcuBeiKL1Zjv1BJ
         aPUli/8qu49Dsl61pTLbR9GWYGA0u8UkEdQdW4J6FBeLUDDFn3R0gElZX5dGYk4SiU2A
         IkuEOmBLl3JDkxP4zV/rJQCIubiRNzBN1Ed4MPO7nelAg6g/ilAIWYs+G9JDnm9Yu9xi
         uC2qiMXfNdGaT3k4JNQ5oMmpwS+xrYUi0062ipV9ZcAuOpWt++yHzXGfyYx5Ll+yDMLU
         wFzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HdcqDhfG82EUtvlrw0QZap1nbV6uDvfkm3HpJPlo97k=;
        b=TIVq9g68DmYZTWQOx4ff00abuZFXoankkfT1y3MeFrP0Ynxx0vvqZSoJTDK0v+T4Gu
         G6iUupEdvDeWiAq3UK5vAv9FEi848N5tTIKjxtOPpKCvaZCIifam/XPSLCFcz+7cwYQp
         8lVl4Xj53S6xZnQQ0GPsHENyaNFQRpoocHMN0AXaEKqUnp2DqlvkG9AzquAoC7CBxJPH
         4N03wI5ceQUhjXTIPOVJutRN/+grK/HtVY/0+I40GX5xJXavoJT5WaJQfNndbgpFh516
         1jj+bhQ63ddqynLu5hxq5WEr5yP7hQS2RRoM1e2noOlsBMBqLesSKt4jArqn0DuPA5UJ
         w5mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=HA0ukVji;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l132sor5067800oia.53.2019.03.18.12.18.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 12:18:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=HA0ukVji;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HdcqDhfG82EUtvlrw0QZap1nbV6uDvfkm3HpJPlo97k=;
        b=HA0ukVjiSGM6vCoGTnAtHewjy1IKBeDEzqSTN1EmJ95+CzZq/5EhXwxcXIM1NCXMD+
         /glsGYlV9UmtivBFLjqHV9QQ7GbWth9DaDm6QVAQvcnZb4Web1OX4FvMsRhreUX7yWiB
         tiKRh/rWHh6ng45fia/UHsCEOK/ICnP10V0Tbwyjt1FSk6lXLMpMAeu0v43+pPnPjQ0Z
         mDRwaFnDiUKDMQ2Ve/woF66FzHi32Ii41XcAIHZ8wwC0is2+hWyNfpKSy/Li8lYAPkSe
         mGbHwoBJ3VASRZK55VUpotTvzJhUuLsrfVKNTrpDb4bYLRqpdYTo+pdfuhT2LKaxo3+b
         3QFQ==
X-Google-Smtp-Source: APXvYqz7JAxUnYYpq/Ry6NBbJEYOU/U1LZttzyxvhYmzm/bgoSYx9C0fzZGd0naQO8DLSWZ5tbhTBO/4DzFlpDz4/4Y=
X-Received: by 2002:aca:aa57:: with SMTP id t84mr293447oie.149.1552936731407;
 Mon, 18 Mar 2019 12:18:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com> <CAPcyv4geu34vgZszALiDxJWR8itK+A3qSmpR+_jOq29whGngNg@mail.gmail.com>
 <20190318185437.GB6786@redhat.com>
In-Reply-To: <20190318185437.GB6786@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Mar 2019 12:18:38 -0700
Message-ID: <CAPcyv4gLyKkboZ-ucHubiHgdpF4i9w+XKhPujjJ=dwU9Vox=Bg@mail.gmail.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, 
	Jason Gunthorpe <jgg@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 11:55 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Mon, Mar 18, 2019 at 11:30:15AM -0700, Dan Williams wrote:
> > On Mon, Mar 18, 2019 at 10:04 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > >
> > > On Wed, Mar 13, 2019 at 09:10:04AM -0700, Andrew Morton wrote:
> > > > On Tue, 12 Mar 2019 21:27:06 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> > > >
> > > > > Andrew you will not be pushing this patchset in 5.1 ?
> > > >
> > > > I'd like to.  It sounds like we're converging on a plan.
> > > >
> > > > It would be good to hear more from the driver developers who will be
> > > > consuming these new features - links to patchsets, review feedback,
> > > > etc.  Which individuals should we be asking?  Felix, Christian and
> > > > Jason, perhaps?
> > > >
> > >
> > > So i am guessing you will not send this to Linus ? Should i repost ?
> > > This patchset has 2 sides, first side is just reworking the HMM API
> > > to make something better in respect to process lifetime. AMD folks
> > > did find that helpful [1]. This rework is also necessary to ease up
> > > the convertion of ODP to HMM [2] and Jason already said that he is
> > > interested in seing that happening [3]. By missing 5.1 it means now
> > > that i can not push ODP to HMM in 5.2 and it will be postpone to 5.3
> > > which is also postoning other work ...
> > >
> > > The second side is it adds 2 new helper dma map and dma unmap both
> > > are gonna be use by ODP and latter by nouveau (after some other
> > > nouveau changes are done). This new functions just do dma_map ie:
> > >     hmm_dma_map() {
> > >         existing_hmm_api()
> > >         for_each_page() {
> > >             dma_map_page()
> > >         }
> > >     }
> > >
> > > Do you want to see anymore justification than that ?
> >
> > Yes, why does hmm needs its own dma mapping apis? It seems to
> > perpetuate the perception that hmm is something bolted onto the side
> > of the core-mm rather than a native capability.
>
> Seriously ?

Yes.

> Kernel is fill with example where common code pattern that are not
> device specific are turn into helpers and here this is exactly what
> it is. A common pattern that all device driver will do which is turn
> into a common helper.

Yes, but we also try not to introduce thin wrappers around existing
apis. If the current dma api does not understand some hmm constraint
I'm questioning why not teach the dma api that constraint and make it
a native capability rather than asking the driver developer to
understand the rules about when to use dma_map_page() vs
hmm_dma_map().

For example I don't think we want to end up with more headers like
include/linux/pci-dma-compat.h.

> Moreover this allow to share the same error code handling accross
> driver when mapping one page fails. So this avoid the needs to
> duplicate same boiler plate code accross different drivers.
>
> Is code factorization not a good thing ? Should i duplicate every-
> thing in every single driver ?

I did not ask for duplication, I asked why is it not more deeply integrated.

> If that's not enough, this will also allow to handle peer to peer
> and i posted patches for that [1] and again this is to avoid
> duplicating common code accross different drivers.

I went looking for the hmm_dma_map() patches on the list but could not
find them, so I was reacting to the "This new functions just do
dma_map", and wondered if that was the full extent of the
justification.

> It does feel that you oppose everything with HMM in its name just
> because you do not like it. It is your prerogative to not like some-
> thing but you should propose something that achieve the same result
> instead of constantly questioning every single comma.

I respect what you're trying to do, if I didn't I wouldn't bother
responding. Please don't put words in my mouth. I think it was
Churchill who said "if two people agree all the time, one of them is
redundant". You're raising questions with HMM that identify real gaps
in Linux memory management relative to new hardware capabilities, I
also think it is reasonable to question how the gaps are filled.

