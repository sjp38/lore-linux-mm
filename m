Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F573C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:13:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B12E120651
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:13:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="tA1aPkae"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B12E120651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6116C6B0005; Tue, 19 Mar 2019 15:13:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C02B6B0006; Tue, 19 Mar 2019 15:13:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 488E46B0007; Tue, 19 Mar 2019 15:13:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 199FB6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:13:54 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id d198so2447624oih.6
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:13:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Hb0TMUCfZsXrifishUIJPpzzpWyGqqsjDKL3oDA7RZw=;
        b=uZqjhXvOaUoymLBRam3jBq+bfNsiQvXEWIujIZX5B9wdXVdPP3lmkROBU8uceDLfp2
         e+jC4bcUn6fp1cTI4RDNAKJplM+IXmQRiNkkF5hzbMjU+oErSVmabuYvmQUbpBE2sx0Z
         +bUwrAvsaqAVvNI1YKvFonRYFBK3GZf0dpsAMrnpoedcOySPUTqcoib0G8Rdkm3O331g
         29oXHHqHGyV1+4EUtVuFid+s+YdqjxqKusxmQz3nQDfpUiDoFJewiJnXp+ROUbg9LQbD
         IqOtkq3E3YL6QhQ9XSekGGOMSRbDT0CtHXYUMlyDRYy1fIdH/AKNQpMiOuGQJV8YYdOw
         KjWw==
X-Gm-Message-State: APjAAAW0XqseMNYgMCqBfC8ryW14RcgCtvowVKuc3NGn6ij7gQjAksmF
	dPt//Qv9ljEuO/QJWJJLfWDdR8nj5veshVLqJ5wnK2fjcceoO4jMv4CfEXsTOCOW+pVg88wyzgo
	Sw9iWdvJXixNyR5USG06apMn6eg4hvo+fuM41VwPpH8F2F1f/KiJOQaZ/j+INxTsKdw==
X-Received: by 2002:aca:cf10:: with SMTP id f16mr2603344oig.42.1553022833541;
        Tue, 19 Mar 2019 12:13:53 -0700 (PDT)
X-Received: by 2002:aca:cf10:: with SMTP id f16mr2603289oig.42.1553022832607;
        Tue, 19 Mar 2019 12:13:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553022832; cv=none;
        d=google.com; s=arc-20160816;
        b=Ca+PCms6fYKnWy9Fb41or/rm9W401DIreXm/c9f12+YAAs9JcIm99iB20gC1Ie/TD3
         LYJTDOJbzlfsn9iKPhUihQ+Ni6unC0M/HHV8KVu3XefJ7fCSBcbot6m6Vs+oza4On4CO
         +z6r1vAJkoOo8u2U8MU1MPKqZahyBY9NANBiuZ8oUm9FfSqf+S1Kp5aVglTDFkZOaDVH
         NEqpq2kOGkNRcN+i0qq1B+Yy//e0fjzVOfUcKdr/EAuQXO0+rjxrq4DDkh1fBuof6g3d
         ENFtosJ8BY6YiDEWUP/+HLBSqFmtXPh74OLOPcBWUdOHlZDkxG58KDgoJa0CJI1XSfFD
         sV6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Hb0TMUCfZsXrifishUIJPpzzpWyGqqsjDKL3oDA7RZw=;
        b=jvMlX78GmTkhQqbosh7vCk49ng69b5qN2+y/GFV7SGEcgPfRCL3GtbL5GBHzHHfguU
         WREBz94kc4lNuKXVPiEv+N3kaGVoeTnLWUAYhgpXouGOgMKbYEk3lOYakVP3AQbrfpES
         7ZHcEidzeO0I55YhqKwcVzH5zJoC/okYXgdzufY5Rw14ZdtF5L+HFiPdi18zDqhsZi+C
         fkP4/jZ8s//nsbFAfsaciWkQzkwgp5W+3Ssb9b9ydfLMVPIHuba/7rx1fjuRcQ4Yj+Pa
         25HcDgFbKOkZX1Vl7V1FonpfgIIHr8rbku9Asmcx0sXdtqJ14rTwCKyxMFIwunIb55Dt
         J36Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=tA1aPkae;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o132sor7426300oih.30.2019.03.19.12.13.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 12:13:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=tA1aPkae;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Hb0TMUCfZsXrifishUIJPpzzpWyGqqsjDKL3oDA7RZw=;
        b=tA1aPkae+04SdhT1KymIG25CYueUBn6ZMXHtyA4R1DHsZP6v9/xxFKjK1f0XAOpgR0
         PIpE9/8sIwPD7EAGecSssTxUVLZjsiDikt8ZhTDFkXe3s9F9gctBxbdG84RNHu7YA6L3
         h/aHxnW6Fhp7ZmkQnRHrbYe+SmlrTcopjpXUdlhiUzROfFa293lEHe/jsqatKAOXYNGy
         hyEP8vO/QCb9zZjMmwqpnuuPUjj1lV5AOmG6CtpDH8vNv3HYhOKtIr8qkS+YqVLn6Zkc
         79zphgtqqD6Uqq3xhnozpHm1IP6m1Tp++4jKCdB6lPk2sn1nA7cEjCsGufszuq41Fhl7
         6SVQ==
X-Google-Smtp-Source: APXvYqzBxrNYRkRQzrHdBRUCSknsQ4I3vdghzH5Ms1E3iCffjEZnyjCciVZjxajeGDVJPFSdiQT6m/kbQDpxrRvkk9c=
X-Received: by 2002:aca:f581:: with SMTP id t123mr2816773oih.0.1553022831762;
 Tue, 19 Mar 2019 12:13:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190313012706.GB3402@redhat.com> <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com> <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
 <20190319165802.GA3656@redhat.com> <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
 <20190319171847.GC3656@redhat.com> <CAPcyv4iesGET_PV-QcdBbxJGgmJ_HhoGczyvb=0+SnLkFDhRuQ@mail.gmail.com>
 <20190319174552.GA3769@redhat.com> <CAPcyv4hFPOO0-=v3ZCNFA=LgE_QCvyFXGqF24Crveoj_NTbq0Q@mail.gmail.com>
 <20190319190528.GA4012@redhat.com>
In-Reply-To: <20190319190528.GA4012@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Mar 2019 12:13:40 -0700
Message-ID: <CAPcyv4hg5Y_NC1iu56zcznYkCRnwg+_7bGFr==7=AC6ii=O=Ng@mail.gmail.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Alex Deucher <alexander.deucher@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 12:05 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Tue, Mar 19, 2019 at 11:42:00AM -0700, Dan Williams wrote:
> > On Tue, Mar 19, 2019 at 10:45 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > >
> > > On Tue, Mar 19, 2019 at 10:33:57AM -0700, Dan Williams wrote:
> > > > On Tue, Mar 19, 2019 at 10:19 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > >
> > > > > On Tue, Mar 19, 2019 at 10:12:49AM -0700, Andrew Morton wrote:
> > > > > > On Tue, 19 Mar 2019 12:58:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> > > > [..]
> > > > > > Also, the discussion regarding [07/10] is substantial and is ongoing so
> > > > > > please let's push along wth that.
> > > > >
> > > > > I can move it as last patch in the serie but it is needed for ODP RDMA
> > > > > convertion too. Otherwise i will just move that code into the ODP RDMA
> > > > > code and will have to move it again into HMM code once i am done with
> > > > > the nouveau changes and in the meantime i expect other driver will want
> > > > > to use this 2 helpers too.
> > > >
> > > > I still hold out hope that we can find a way to have productive
> > > > discussions about the implementation of this infrastructure.
> > > > Threatening to move the code elsewhere to bypass the feedback is not
> > > > productive.
> > >
> > > I am not threatening anything that code is in ODP _today_ with that
> > > patchset i was factering it out so that i could also use it in nouveau.
> > > nouveau is built in such way that right now i can not use it directly.
> > > But i wanted to factor out now in hope that i can get the nouveau
> > > changes in 5.2 and then convert nouveau in 5.3.
> > >
> > > So when i said that code will be in ODP it just means that instead of
> > > removing it from ODP i will keep it there and it will just delay more
> > > code sharing for everyone.
> >
> > The point I'm trying to make is that the code sharing for everyone is
> > moving the implementation closer to canonical kernel code and use
> > existing infrastructure. For example, I look at 'struct hmm_range' and
> > see nothing hmm specific in it. I think we can make that generic and
> > not build up more apis and data structures in the "hmm" namespace.
>
> Right now i am trying to unify driver for device that have can support
> the mmu notifier approach through HMM. Unify to a superset of driver
> that can not abide by mmu notifier is on my todo list like i said but
> it comes after. I do not want to make the big jump in just one go. So
> i doing thing under HMM and thus in HMM namespace, but once i tackle
> the larger set i will move to generic namespace what make sense.
>
> This exact approach did happen several time already in the kernel. In
> the GPU sub-system we did it several time. First do something for couple
> devices that are very similar then grow to a bigger set of devices and
> generalise along the way.
>
> So i do not see what is the problem of me repeating that same pattern
> here again. Do something for a smaller set before tackling it on for
> a bigger set.

All of that is fine, but when I asked about the ultimate trajectory
that replaces hmm_range_dma_map() with an updated / HMM-aware GUP
implementation, the response was that hmm_range_dma_map() is here to
stay. The issue is not with forking off a small side effort, it's the
plan to absorb that capability into a common implementation across
non-HMM drivers where possible.

