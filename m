Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FF2EC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 20:04:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8EB92070C
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 20:03:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="dcd3JYDJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8EB92070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F5896B0003; Tue,  6 Aug 2019 16:03:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A4326B0006; Tue,  6 Aug 2019 16:03:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 443DE6B0007; Tue,  6 Aug 2019 16:03:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7C46B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 16:03:59 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k31so80122917qte.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 13:03:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=X4WStm4sd99gxcsiHRK905oUotgl76w2o1W1C4yVJ6I=;
        b=HK5Q4FSmLyysWMYxcpipcLL6FVsmf2Y5/nJOXdOQ9dQQ0MQ+vSDzFsUMB5goEzrbfi
         IMzEoFivdnPmNrGIMeyK4cq+sieJyNVuiNgW3Q5FIHEKdw70eQk3BsYPUwq2YlrCEaoX
         uVLEfRWGn2kwzcsGv6E5qmMG57YRiVcLx0XANhT14wrvBMOr/tWu2pq8WqPKg0NJcpAP
         66b7xA54GBYBgOsaw6YYmUDNVKqiqP/ChIkR/oorrom456oGntNfiCG1vd5ojgrTK0b5
         dDvQpkVRy3xpV9qriP7mswKb32iVQaiZ99Mv2k919E2/VbfBM77HkD4/I/kr+Eqpm34R
         rh+g==
X-Gm-Message-State: APjAAAXQokC/VTTLg09N9x/adXdlCnEp0sHuuW58qYJ+oHfA+DzKGDi1
	c+X8j/fYIyN9OWG5fjI+97WV9uMFR1x4PgmYak+ShCh01cgliWDgtQeWqnBDX7jJMwCa7jgyx1z
	oA2UGuNtwUWIAL7pBFopRMI1fppxheQmNOyGcEdQCD4cHrciZ7XEKTe56Xh1i/Ap/Dw==
X-Received: by 2002:ac8:22a3:: with SMTP id f32mr4770595qta.152.1565121838860;
        Tue, 06 Aug 2019 13:03:58 -0700 (PDT)
X-Received: by 2002:ac8:22a3:: with SMTP id f32mr4770530qta.152.1565121838155;
        Tue, 06 Aug 2019 13:03:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565121838; cv=none;
        d=google.com; s=arc-20160816;
        b=o3JiqtzS20q5Iqw8GU/MRN2TFUWoHwGS7n9taXkc9dfTIC3dgqkFEvv2giUB0xhU8C
         K2PTvYbD4dLBUbLKCyEn/UQZz4FD20Wg9kVnXEQCNbQ8pC3kb/4Dd3hR7GQGD/GnQjED
         z6PXQX77H8BJAKv2u4QxTZ/dA/5rFEoU4XTc75x6viIjHj21pD9DK8QB8EBPsEhcWxyo
         CSnk8dOzRPP+RqL0P9TVWhyScRhlbwr+1ptv9e7ANcZ3eaDVzGgXNleaU2BYVMtXXaFM
         Vdo6DPyFls2idj/E7LbLstnQW+bi2XUZX1brhuZ0XavuO2WdWQfiMyZtFP7Sbl4UdN0z
         2pPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=X4WStm4sd99gxcsiHRK905oUotgl76w2o1W1C4yVJ6I=;
        b=inj60ZKoT/fr6n+M8WmuzlmsKoB0D7jb2CkpUDZze4ct42UkPTuq67spW5gYDQvLVm
         V3VFsGPVALj7t1TfICa3/2PUfWn9DQ3zeCg05esOKAP9LbQtLOwkNfeJT4B968dtz1ck
         T6LN6Q6MS4rGAvJI6tN1LC44afok3h1ootQPS1aAskYlwLbKSNTAMEd99DkrcGCMfGKl
         K9uJG3Dt3GspJUhmcB7qTdhnYsvgdgd8YPLRw7KHQlewU/KTc0cLx4Sr/a7Pqz/LbFUg
         8kliVu6C/wR4MVf2Emec8zQzue7KCIH4mU7NnGWDcRY+shyBjSvQ3GmFDB2q+TMMGzme
         PoNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dcd3JYDJ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b11sor114925774qtc.50.2019.08.06.13.03.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 13:03:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dcd3JYDJ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=X4WStm4sd99gxcsiHRK905oUotgl76w2o1W1C4yVJ6I=;
        b=dcd3JYDJk152NlFfhO/9qO7tld2EmCF8YFkFxS8Gs6O3Eoi2v5a/p+kLVV72KaaDZH
         4AOPO6UQwsqqSpKlkkmk62Hxppen7/IFJKSpOLIvaEcL3N5LOWdJcJ3uwdOeXMO99Q9Q
         Y+QyzsRM0n6nW3nAnKygZxiG5A+b6hJR/51n9u0k+imi9/6Ip/PFhv8jDVoF1QLCfhOE
         mc8U5KqjaSeDQJIru7Rkv0aQxcqZ/bBs3+8ohxG0EleOYIJ0yGSZ17/3ZQ9kmYzGdGc9
         lnGhK+bfHIxMwOWyuDrIFwNQZiRvrAKnQOXdx2VYo9gZpFBLdNdodmHnLp7wXWjv5EFF
         EsSQ==
X-Google-Smtp-Source: APXvYqx6UY5l/vYT32k/wTnl8SPfwuXYE5Fx1fiKKYFrCmOXi/6TIYwyn3yhKlGhO9HMcVXQYwiuNw==
X-Received: by 2002:ac8:3118:: with SMTP id g24mr4769493qtb.390.1565121837686;
        Tue, 06 Aug 2019 13:03:57 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id g10sm35341761qki.37.2019.08.06.13.03.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 13:03:57 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv5ga-0003dB-O6; Tue, 06 Aug 2019 17:03:56 -0300
Date: Tue, 6 Aug 2019 17:03:56 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Alex Deucher <alexdeucher@gmail.com>
Cc: "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Christoph Hellwig <hch@lst.de>,
	"Deucher, Alexander" <Alexander.Deucher@amd.com>,
	"Koenig, Christian" <Christian.Koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH 15/15] amdgpu: remove CONFIG_DRM_AMDGPU_USERPTR
Message-ID: <20190806200356.GU11627@ziepe.ca>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-16-hch@lst.de>
 <20190806174437.GK11627@ziepe.ca>
 <587b1c3c-83c4-7de9-242f-6516528049f4@amd.com>
 <CADnq5_Puv-N=FVpNXhv7gOWZ8=tgBD2VjrKpVzEE0imWqJdD1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADnq5_Puv-N=FVpNXhv7gOWZ8=tgBD2VjrKpVzEE0imWqJdD1A@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 02:58:58PM -0400, Alex Deucher wrote:
> On Tue, Aug 6, 2019 at 1:51 PM Kuehling, Felix <Felix.Kuehling@amd.com> wrote:
> >
> > On 2019-08-06 13:44, Jason Gunthorpe wrote:
> > > On Tue, Aug 06, 2019 at 07:05:53PM +0300, Christoph Hellwig wrote:
> > >> The option is just used to select HMM mirror support and has a very
> > >> confusing help text.  Just pull in the HMM mirror code by default
> > >> instead.
> > >>
> > >> Signed-off-by: Christoph Hellwig <hch@lst.de>
> > >>   drivers/gpu/drm/Kconfig                 |  2 ++
> > >>   drivers/gpu/drm/amd/amdgpu/Kconfig      | 10 ----------
> > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c |  6 ------
> > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h | 12 ------------
> > >>   4 files changed, 2 insertions(+), 28 deletions(-)
> > > Felix, was this an effort to avoid the arch restriction on hmm or
> > > something? Also can't see why this was like this.
> >
> > This option predates KFD's support of userptrs, which in turn predates
> > HMM. Radeon has the same kind of option, though it doesn't affect HMM in
> > that case.
> >
> > Alex, Christian, can you think of a good reason to maintain userptr
> > support as an option in amdgpu? I suspect it was originally meant as a
> > way to allow kernels with amdgpu without MMU notifiers. Now it would
> > allow a kernel with amdgpu without HMM or MMU notifiers. I don't know if
> > this is a useful thing to have.
> 
> Right.  There were people that didn't have MMU notifiers that wanted
> support for the GPU.

?? Is that even a real thing? mmu_notifier does not have much kconfig
dependency.

Jason

