Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F5E8C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:46:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D89522086D
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:46:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="U08Ufgqo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D89522086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63D9E6B0007; Wed,  7 Aug 2019 07:46:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D0546B0008; Wed,  7 Aug 2019 07:46:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48ECB6B000A; Wed,  7 Aug 2019 07:46:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 267DF6B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 07:46:36 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d11so78830286qkb.20
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 04:46:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9tcMRoCrJOgypBCjgMnEianhaeJlCGMLrqGgBoLjIDU=;
        b=NKheLfl1pJ6I3B2ji2R11ZBTgmY6GTqvFATvJBNbF60NTc57BGW7n6mdyUfrXI9iEh
         e9KGUSheZHDVRmrS3znNZKjHWayEIJUqlKYcKfBSd9ivRoVFAgoHKqc0PItoFwz35b1Q
         FCrX5AWap98xREbnWDf143TjTE/VFIwsochoXecYPi4BzVa+jpA0HuVJaSnkN3VxqI2m
         HJMGOVAqssjVNPwA0yalN3nrvhrwoRKEBVQXimqYbUvUGSqx8ffgHjv+yeuObuuGqGzL
         gFPKIziYUc8ske47QmR+wPyWLskwiNFTztf9x9B4M7ywrmZKqbv+yZpJxliv1VbtHrup
         MBCg==
X-Gm-Message-State: APjAAAW2R2MvezEw1A1wLiDI/Wxo1RiX+51g/0AarDfRJ9rhJjOxs+2y
	wCHdZBlrl+GX5J9z7D6yBtnsLb4IrVjtKEgQizjhaRRh1TW5JuBdVWc4Nd2HEyOSHZZom4FmesG
	FWPpdy5PkPfd36gWr4V2P3VI/fBhTYu1QqpYY7l6lkqyic/ayJFE88X0VswdC6SmbtQ==
X-Received: by 2002:a0c:98e9:: with SMTP id g38mr7511027qvd.187.1565178395901;
        Wed, 07 Aug 2019 04:46:35 -0700 (PDT)
X-Received: by 2002:a0c:98e9:: with SMTP id g38mr7510993qvd.187.1565178395254;
        Wed, 07 Aug 2019 04:46:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565178395; cv=none;
        d=google.com; s=arc-20160816;
        b=ZhOOpygQlDw1d1Hs6J5Op63qp5Vwy2mvh55DctU1lAaLxsrsfnNHNO9PrKt68Hl3CF
         0JaFSLw+e/PRs3eobPs3sUNb3bnvacXroKc9uAn4xQgQWPr6MoGFMTOuEqu14fb63+fy
         sK5kJGo30wayJ2aGyZj4qVfvl1lQqgigi+xGldDffWMoTe3mSWE56MBy10qklxrXi1Y7
         A6dXXFS0NkBN+dlozH6fwWPe5lcK/rXzCmDMJF6jaH8dHObEPvx/U5Kc6obaAM0LGuk+
         PWwytVnVShm5SwnWTBsMd/53J0H6rPLqk2PGwWP9fbcXvI1ZA+9SKzW0PY49JZm7x+1p
         P0hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9tcMRoCrJOgypBCjgMnEianhaeJlCGMLrqGgBoLjIDU=;
        b=wP77EVIcExkq52X9KpqlfO4DkOS7e6XIPXr42AQPAP2bZI+M42t72gO2rWc9wO/ypo
         ZQcHpcIY5Uv2Mi9RagMoidgx3w9GuQP8zhPNvOtREZb8l1kqhy7Vz4EmDGt7VkzsDOmP
         UcGLRzK4reEoSn27I9FxC2BhPY6yeuteYNLJBCELzyINYr76dfJYNoJhOzvfRxVRDb7f
         lOllCfapyQj+Z4PbuUaIJZ4ofAZ75TFO5agfM0Jo/Dpe6Vi0iWBdq+pB8ClEoMTKRfp1
         KLzuryATCrbkiz5OKaWvpQII+vACq4OXtSSoIL+958xPFC1cJLB6lzaYGpbXweOiF/RE
         DxYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=U08Ufgqo;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor442020qtq.33.2019.08.07.04.46.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 04:46:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=U08Ufgqo;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9tcMRoCrJOgypBCjgMnEianhaeJlCGMLrqGgBoLjIDU=;
        b=U08UfgqoDECwAr2QVZQUgZK40EFADE7BB9s9xvrIZg9BnRq7d95CB83a2OkP1WEJcj
         FJHxKesZGFWoqIF2Qvx18DQ0QvKbjikgKunvpDQdaSIZ0xtKT4N7Aaxnh+uo7IY4chsI
         EfR9d/3Agjm/w1qM55xjv8+yMuR6GmpagkJuTiZ1huMV62pE12VP4QStafaX4bqEbCF5
         nKofSYhlitBlOo14ZSx+w2EM6o/0BqEsL16SZ9EMLbCiY4rRVsTQde2O8lzNMJEb+Cq/
         Vx2rLEgsoxjAWUNTBox+Ov8foZ2VXl/0VY0B4PKb+rOpSVgQBrfb34kDq3jWYLCsqCZd
         XwCA==
X-Google-Smtp-Source: APXvYqwgiLU0pSR3tJqkM4Nqx6SM116MNW2dWYs7m0gkaOSNuRmQOq6FVBT9RTAhBGfUW5xdKQEVPQ==
X-Received: by 2002:aed:24d9:: with SMTP id u25mr7755713qtc.111.1565178394864;
        Wed, 07 Aug 2019 04:46:34 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a135sm40043046qkg.72.2019.08.07.04.46.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 04:46:34 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hvKOn-0000fJ-NF; Wed, 07 Aug 2019 08:46:33 -0300
Date: Wed, 7 Aug 2019 08:46:33 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Koenig, Christian" <Christian.Koenig@amd.com>
Cc: Alex Deucher <alexdeucher@gmail.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Christoph Hellwig <hch@lst.de>,
	"Deucher, Alexander" <Alexander.Deucher@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH 15/15] amdgpu: remove CONFIG_DRM_AMDGPU_USERPTR
Message-ID: <20190807114633.GA1557@ziepe.ca>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-16-hch@lst.de>
 <20190806174437.GK11627@ziepe.ca>
 <587b1c3c-83c4-7de9-242f-6516528049f4@amd.com>
 <CADnq5_Puv-N=FVpNXhv7gOWZ8=tgBD2VjrKpVzEE0imWqJdD1A@mail.gmail.com>
 <20190806200356.GU11627@ziepe.ca>
 <4a040a3f-8981-3e94-2436-8295a0caa534@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4a040a3f-8981-3e94-2436-8295a0caa534@amd.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 06:57:24AM +0000, Koenig, Christian wrote:
> Am 06.08.19 um 22:03 schrieb Jason Gunthorpe:
> > On Tue, Aug 06, 2019 at 02:58:58PM -0400, Alex Deucher wrote:
> >> On Tue, Aug 6, 2019 at 1:51 PM Kuehling, Felix <Felix.Kuehling@amd.com> wrote:
> >>> On 2019-08-06 13:44, Jason Gunthorpe wrote:
> >>>> On Tue, Aug 06, 2019 at 07:05:53PM +0300, Christoph Hellwig wrote:
> >>>>> The option is just used to select HMM mirror support and has a very
> >>>>> confusing help text.  Just pull in the HMM mirror code by default
> >>>>> instead.
> >>>>>
> >>>>> Signed-off-by: Christoph Hellwig <hch@lst.de>
> >>>>>    drivers/gpu/drm/Kconfig                 |  2 ++
> >>>>>    drivers/gpu/drm/amd/amdgpu/Kconfig      | 10 ----------
> >>>>>    drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c |  6 ------
> >>>>>    drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h | 12 ------------
> >>>>>    4 files changed, 2 insertions(+), 28 deletions(-)
> >>>> Felix, was this an effort to avoid the arch restriction on hmm or
> >>>> something? Also can't see why this was like this.
> >>> This option predates KFD's support of userptrs, which in turn predates
> >>> HMM. Radeon has the same kind of option, though it doesn't affect HMM in
> >>> that case.
> >>>
> >>> Alex, Christian, can you think of a good reason to maintain userptr
> >>> support as an option in amdgpu? I suspect it was originally meant as a
> >>> way to allow kernels with amdgpu without MMU notifiers. Now it would
> >>> allow a kernel with amdgpu without HMM or MMU notifiers. I don't know if
> >>> this is a useful thing to have.
> >> Right.  There were people that didn't have MMU notifiers that wanted
> >> support for the GPU.
> > ?? Is that even a real thing? mmu_notifier does not have much kconfig
> > dependency.
> 
> Yes, that used to be a very real thing.
> 
> Initially a lot of users didn't wanted mmu notifiers to be enabled 
> because of the performance overhead they costs.

Seems strange to hear these days, every distro ships with it on, it is
needed for kvm.

> Then we had the problem that HMM mirror wasn't available on a lot of 
> architectures.

Some patches for hmm are ready now that will fix this

Jason

