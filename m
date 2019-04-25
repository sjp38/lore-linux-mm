Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9567CC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:43:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB36A2088F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:43:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="PgBQCkgf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB36A2088F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCB666B0005; Thu, 25 Apr 2019 11:43:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C51ED6B0008; Thu, 25 Apr 2019 11:43:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1B2F6B000A; Thu, 25 Apr 2019 11:43:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 804206B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:43:21 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id k90so167430otk.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:43:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MuBi+pyE+MOOcRNjrNHKnCL59LtxHiwnpVdboRz7mt4=;
        b=LO+KNPrvSuhViln5MR/td6LkkAQTn5AR0B1F6zjBpiyT8CcRPCmcfc79NE7Gd360FO
         9rjkp71kBsAE4UNlMbf8VHtSnA2rhBr5HPwHtNpPHehifrnPDJVBAyd5EWt4pxuiuIh2
         mFABe0TKlDCd3gR8mVE4SqkizNJpoU0yeu09fWs80FFU0taYGjXT8LHNmBS/aPid9nSV
         EGPEQ8VIvsV546OEiuCLRBJAQcVhhZ6YMg69sLs0fuVMbr3MUEZ1xj4nuaoiaBHZFRUs
         dXcbiJStMLI/RO8yz/6Jhlo8fqqlSN2oPSVgOOv5rElKmoZv2BZkXCnFFaqagtLfhkWU
         V8Bg==
X-Gm-Message-State: APjAAAWOPxRelw7bNWQ42VZyzk5EhjLaRhm7TE4YvS+WXw5yvQdcUnbB
	a72rFw6PBFXOk0gy8QyzCtZSRkMBV4SkXa7yDcJDhgbp929+N7U5kGJgZ+PHgb5miuSaWUmHUjj
	dIKr6mld3pxXNHZPXIRdbsrkbu1jf9JfBRwUleo50NpgKdIah9AubfNUXsYBMewiJzw==
X-Received: by 2002:aca:388a:: with SMTP id f132mr3737522oia.65.1556207001122;
        Thu, 25 Apr 2019 08:43:21 -0700 (PDT)
X-Received: by 2002:aca:388a:: with SMTP id f132mr3737479oia.65.1556207000416;
        Thu, 25 Apr 2019 08:43:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556207000; cv=none;
        d=google.com; s=arc-20160816;
        b=oKtnnebWXD8OzFA5eiXdI1iv4WcdFD7U+yzjRpSgH8HhbkEEWeK3nXF0GhlC6jSW9r
         ccTjTjz9xWm+adJ0T2FX8J+i+ALC6ddFke32KLOAZzJJESu4GTefiKqbBJgT0VBUyCNn
         SVQPUEReUvVhYSFHVtrD88tow/ZPceU2OUld2PRhqN3GsSf0MirRdp7Z/EmKFYc8qINy
         Rds+I5l961pQSxkWKL675x8KmXCm7uwlHxIr3wCmiXnRw7j8hzpJddhL5oVFNyukjFZz
         ER6wS9H+wbOEfhPtSNS55+eY2PdIJYJtWttExfQJpH7PnU/kiguUAlMIY+gBon7csIna
         /eOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MuBi+pyE+MOOcRNjrNHKnCL59LtxHiwnpVdboRz7mt4=;
        b=OWf45yF+DEqkABcG9Ho7cXai7gKX1xD4lBHBAQLR0CgL6nlRM4qMnZWaYNjHZ5BMUb
         cwHrnXz+ct0IdCAdu9TJMuUPFM5iY7LzTOwXGte9l45qnfV15D8Z06a9q5VVh3cpc+E9
         Ry26BM+pzZXA97G3Ar0nAiGxWLDj3q0KeQlSJq4FiEMkmDWNlSJe1DDycyvJ2aRlYSyP
         3OI58kmORC1RI6RdmzUeKl7qGZFGPYN8bdOF+2g4rKQmTaTLiaB1X3oJibB/C1Mj/rHG
         KbHYULsCA8lqxJPsfYfHLDI/Yaif4wflC9pDb7f0cDvrxiBf5NVJFvrBUJhIu6zfEq38
         le/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=PgBQCkgf;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l137sor10450913oig.77.2019.04.25.08.43.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 08:43:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=PgBQCkgf;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MuBi+pyE+MOOcRNjrNHKnCL59LtxHiwnpVdboRz7mt4=;
        b=PgBQCkgfUCim04cuwnDmnemk3z/ZFT/C2b6DYjYzFkGTLFkcRrTDmHsXRJwnZHl64b
         CPaXmduTcgjyVzlZ1ixVUis/CefjAKGilmfm8E/mR+d8REyVvnMB/+CIF43KARwsOA2W
         1qvHm5R6LrwuLqq8sLktOwb79BjFRMcphHhTwzyTESoJKzE9bZE7lGGtWDF6PCGiRYTX
         txMvPPtEcbNjOIkSGLJQjut2VzK/uVNcenvDdoOI6g9O44AM6tKHt838/NnBJYhnihBr
         rc4UpJf2Mdve5s2OAAUPqpL6v1KKgLDOTHzxSUnn9foNkP8HZ+CUTL2p8SEJheb3Jb4z
         AHmA==
X-Google-Smtp-Source: APXvYqwh3PqfR5/vPjV4UUBzcmSSGH7mhUnUhfc/+cpUrRl0aKmdC7Xo6E468HAZnrkNTvvruta71ETSn2xWCclxVpk=
X-Received: by 2002:aca:de57:: with SMTP id v84mr3927177oig.149.1556206999786;
 Thu, 25 Apr 2019 08:43:19 -0700 (PDT)
MIME-Version: 1.0
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <20190425063727.GJ12751@dhcp22.suse.cz> <5A90DA2E42F8AE43BC4A093BF067884825785EE8@SHSMSX104.ccr.corp.intel.com>
 <20190425075353.GO12751@dhcp22.suse.cz> <5A90DA2E42F8AE43BC4A093BF067884825785F6E@SHSMSX104.ccr.corp.intel.com>
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF067884825785F6E@SHSMSX104.ccr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 25 Apr 2019 08:43:08 -0700
Message-ID: <CAPcyv4jpiPg+dbFg0BrNSqGjxKA6CQdBiLp5L=nrLWzN7mD8Kw@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] New fallback workflow for heterogeneous memory system
To: "Du, Fan" <fan.du@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, 
	"Hansen, Dave" <dave.hansen@intel.com>, 
	"xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "Huang, Ying" <ying.huang@intel.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 1:05 AM Du, Fan <fan.du@intel.com> wrote:
>
>
>
> >-----Original Message-----
> >From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> >Behalf Of Michal Hocko
> >Sent: Thursday, April 25, 2019 3:54 PM
> >To: Du, Fan <fan.du@intel.com>
> >Cc: akpm@linux-foundation.org; Wu, Fengguang <fengguang.wu@intel.com>;
> >Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
> ><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
> ><ying.huang@intel.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org
> >Subject: Re: [RFC PATCH 0/5] New fallback workflow for heterogeneous
> >memory system
> >
> >On Thu 25-04-19 07:41:40, Du, Fan wrote:
> >>
> >>
> >> >-----Original Message-----
> >> >From: Michal Hocko [mailto:mhocko@kernel.org]
> >> >Sent: Thursday, April 25, 2019 2:37 PM
> >> >To: Du, Fan <fan.du@intel.com>
> >> >Cc: akpm@linux-foundation.org; Wu, Fengguang
> ><fengguang.wu@intel.com>;
> >> >Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
> >> ><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
> >> ><ying.huang@intel.com>; linux-mm@kvack.org;
> >linux-kernel@vger.kernel.org
> >> >Subject: Re: [RFC PATCH 0/5] New fallback workflow for heterogeneous
> >> >memory system
> >> >
> >> >On Thu 25-04-19 09:21:30, Fan Du wrote:
> >> >[...]
> >> >> However PMEM has different characteristics from DRAM,
> >> >> the more reasonable or desirable fallback style would be:
> >> >> DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3.
> >> >> When DRAM is exhausted, try PMEM then.
> >> >
> >> >Why and who does care? NUMA is fundamentally about memory nodes
> >with
> >> >different access characteristics so why is PMEM any special?
> >>
> >> Michal, thanks for your comments!
> >>
> >> The "different" lies in the local or remote access, usually the underlying
> >> memory is the same type, i.e. DRAM.
> >>
> >> By "special", PMEM is usually in gigantic capacity than DRAM per dimm,
> >> while with different read/write access latency than DRAM.
> >
> >You are describing a NUMA in general here. Yes access to different NUMA
> >nodes has a different read/write latency. But that doesn't make PMEM
> >really special from a regular DRAM.
>
> Not the numa distance b/w cpu and PMEM node make PMEM different than
> DRAM. The difference lies in the physical layer. The access latency characteristics
> comes from media level.

No, there is no such thing as a "PMEM node". I've pushed back on this
broken concept in the past [1] [2]. Consider that PMEM could be as
fast as DRAM for technologies like NVDIMM-N or in emulation
environments. These attempts to look at persistence as an attribute of
performance are entirely missing the point that the system can have
multiple varied memory types and the platform firmware needs to
enumerate these performance properties in the HMAT on ACPI platforms.
Any scheme that only considers a binary DRAM and not-DRAM property is
immediately invalidated the moment the OS needs to consider a 3rd or
4th memory type, or a more varied connection topology.

[1]: https://lore.kernel.org/lkml/CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com/

[2]: https://lore.kernel.org/lkml/CAPcyv4it1w7SdDVBV24cRCVHtLb3s1pVB5+SDM02Uw4RbahKiA@mail.gmail.com/

