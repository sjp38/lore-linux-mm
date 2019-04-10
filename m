Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A601C10F14
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 21:53:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56B5E20830
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 21:53:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Msrizkcs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56B5E20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDF116B0003; Wed, 10 Apr 2019 17:53:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E667E6B0005; Wed, 10 Apr 2019 17:53:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D09F96B0007; Wed, 10 Apr 2019 17:53:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 940346B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 17:53:38 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j184so2907000pgd.7
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 14:53:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=3p4NjpgsoDwbHSH6o2K2Uu1LYIhK93bOWHp3cUQbm2A=;
        b=jH39nE0kzaTXM4S0txskC7StUqWQrqNmQ5sPIeuB4gJpu6blRl5Skv9RTNPCYyg8ex
         NxpEKqlkg0ULEIQxz+WhdSCY5qkQWxxLqfjfHbpoC3d0aBrx5h2RlVL3gzul2cMkz0Hy
         EH6X9z+Ja2TvSJOYqTUiix1fj6NYA7jDxdNCiA0+aQdvcFEGJBrObbISwsVSonEp5TG9
         BlGkurza8056D/0U+bSDsN7kCm2DlsunTdEUqJ6ayYaY5BYEXIHSKiD5K5FgHi2Iqr1p
         KwRIK4daSdjMn+XyfmjMMOlbpobBmEt9778Na4+YhLtnI5GX02xn/w3eSfbpk2DVcsgU
         TKIA==
X-Gm-Message-State: APjAAAXyBDg8/1d8vna2jeTXaG2hW4E+mGD/nb6Nnl3qQ5eHo2lD7rio
	W/4l1e13B4XsqB0BzjgUru6/rI41l+H9pVdocxRAgIxgPviPHunQmO6i592IwBYb0k8asLksLAx
	TB/afFPKWoTcKdWMUovOYcWedWhyldC7VHfnY0MOxDINi1X6xSRXfONqUTM35Hlyvyw==
X-Received: by 2002:a63:1918:: with SMTP id z24mr41440912pgl.406.1554933217455;
        Wed, 10 Apr 2019 14:53:37 -0700 (PDT)
X-Received: by 2002:a63:1918:: with SMTP id z24mr41440890pgl.406.1554933216742;
        Wed, 10 Apr 2019 14:53:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554933216; cv=none;
        d=google.com; s=arc-20160816;
        b=CoHAb9mRggqpmrsWMC4ekeucXW4Ye3F2b2C8Nqw3CWeFFKOEbuSwj39d1HDvMwOn6J
         3syGGqDsMpits1MpOWGwYSYPt012iz/nlIFDMrRo+umOypFIU/2J8REleslYAa/cEVP/
         LD23yD7VhQ9NLC1yVMWA2XUPcnvSBr/EotW9eJ9VaTVjKmV3d8MuxRoGsUsl4Nckq6JC
         YGYO5yuUohrta/FFcj44MTI5gOe0yF1BuL+wXULko2ydZpnd4k42NFFcxp6sv7uAjJKe
         /txWOVBI/2JrUo7EwBXT1l3Zej8UeUXxJeP5G3DfQg6NDNUwkhaSdwPBuGfcqYeUpQqg
         6q2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=3p4NjpgsoDwbHSH6o2K2Uu1LYIhK93bOWHp3cUQbm2A=;
        b=uAe7o2+MBclZBP1I7P9gIx1goSzH4CZcJjMNHwWWoOCC4jjVvhT82XgldNWTHfFGW/
         9bNQkwnaDPPV9hl0qrraP3Vv3A+TFas1SYlhAdsVAbKuSgZYOBJsyYKxCsRRJy3TDEqz
         DSQPLckzcYmjFimo1GSe183000ht5TAyp8ariX4oCfgRrGbee4tcKpEn90WaV4teGJbV
         cpqA985L+ww7lzEPEjdvFBMITS7Rw/MactGPiHFIIKtepkvEp0cu6GJxjEq3h5gSewSs
         iCyE+P6Acrfz9kbT7TrtopyOeTtltQMDkJ0fio18jl+tu3kuJAs9Xy3LiGhGI+9KRgSK
         xmeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Msrizkcs;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j3sor39576344plk.38.2019.04.10.14.53.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 14:53:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Msrizkcs;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=3p4NjpgsoDwbHSH6o2K2Uu1LYIhK93bOWHp3cUQbm2A=;
        b=MsrizkcsUEOZCuBtc2jjJ33ioMjLFHRiq8EFcPhxHCxgPgPD0/aZP86p7dL55H6EkJ
         NgWmq+jptlJZdv043JixiEwvFb7TZKI7KHbJn30hSDYNhwzSV5yliJ37T7PSzn1vSXUZ
         SFL4WG4WJiRMozOWJov6H5uI5Iwv0WRgqGDmdscGoDpEJGFSrYfOOVp73gi0JJp9NzOF
         Do4Mxw4mxX/ucfurwHCr+/exhwgraTzHqinP9/gK9uBaTY6B+RjK0HrkhoqfDMdsndxq
         f76oQL5lDV8iQZ/JbsJ63T5Lqe0AZ+d3zKSnUAYQAVpFRSK4vOGAjlL/FdKKyWkeaMKB
         4sGQ==
X-Google-Smtp-Source: APXvYqxGdiqeWQvkUegBTUaHtm5pmYo5S6GNdOzi04jd1a95COMWNcI4JqF9CNZ55MCrPvzoo7ut9w==
X-Received: by 2002:a17:902:be09:: with SMTP id r9mr44752098pls.215.1554933215988;
        Wed, 10 Apr 2019 14:53:35 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id v19sm66087651pfa.138.2019.04.10.14.53.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Apr 2019 14:53:35 -0700 (PDT)
Date: Wed, 10 Apr 2019 14:53:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Vlastimil Babka <vbabka@suse.cz>
cc: "Tobin C. Harding" <tobin@kernel.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, 
    Qian Cai <cai@lca.pw>, Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
In-Reply-To: <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
Message-ID: <alpine.DEB.2.21.1904101452340.100430@chino.kir.corp.google.com>
References: <20190410024714.26607-1-tobin@kernel.org> <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Apr 2019, Vlastimil Babka wrote:

> On 4/10/19 4:47 AM, Tobin C. Harding wrote:
> > Recently a 2 year old bug was found in the SLAB allocator that crashes
> > the kernel.  This seems to imply that not that many people are using the
> > SLAB allocator.
> 
> AFAIK that bug required CONFIG_DEBUG_SLAB_LEAK, not just SLAB. That
> seems to imply not that many people are using SLAB when debugging and
> yeah, SLUB has better debugging support. But I wouldn't dare to make the
> broader implication :)
> 
> > Currently we have 3 slab allocators.  Two is company three is a crowd -
> > let's get rid of one. 
> > 
> >  - The SLUB allocator has been the default since 2.6.23
> 
> Yeah, with a sophisticated reasoning :)
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a0acd820807680d2ccc4ef3448387fcdbf152c73
> 
> >  - The SLOB allocator is kinda sexy.  Its only 664 LOC, the general
> >    design is outlined in KnR, and there is an optimisation taken from
> >    Knuth - say no more.
> > 
> > If you are using the SLAB allocator please speak now or forever hold your peace ...
> 
> FWIW, our enterprise kernel use it (latest is 4.12 based), and openSUSE
> kernels as well (with openSUSE Tumbleweed that includes latest
> kernel.org stables). AFAIK we don't enable SLAB_DEBUG even in general
> debug kernel flavours as it's just too slow.
> 
> IIRC last time Mel evaluated switching to SLUB, it wasn't a clear
> winner, but I'll just CC him for details :)
> 

We also use CONFIG_SLAB and disable CONFIG_SLAB_DEBUG for the same reason.

