Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E993BC282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 22:04:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7530A20859
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 22:04:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="ORWiaI+Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7530A20859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFEB26B0003; Sat, 20 Apr 2019 18:04:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAE086B0006; Sat, 20 Apr 2019 18:04:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9E326B0007; Sat, 20 Apr 2019 18:04:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B61E6B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 18:04:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id j3so4405682edb.14
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 15:04:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ldGakbeMe/Lt2zN3VzkUpoUzBgNiYR8VYYlH08lu4Jo=;
        b=TMw8OSn/12mx1jJTmFxYrgujVDlHdmctyd6cJJyddI5NUresMYqs6yvt4PNGtoEI/T
         IVzQQipYPwkKtqS/TcDg2EwhPZ8h5zmThMvtxFkrtc9amFLDhmxo15ZxKjaPA/8s7gCK
         S/54j4kmi8W7tBAgm7qpeCW8Snvc+MQ35y0xEqAxk3sl0qUILIRcxS2QqfFnCfS2UyL1
         eYS7hh07I3LhhQGjPZ3ViFOYJZNC6PY682DskvulmUtLdB4Dqj2W+8ptqaiGxwfGg9Oo
         +AcJpYORvIhFC/4BpzUsayB6eDzfR0DtpRaXoBcBpMMteO1/CagFX+hd1OJ+/fXBB2zj
         fYaQ==
X-Gm-Message-State: APjAAAXJMiPi1JOMLbihrhwuHE4BXBf836yqUQZC3jLqowejD7WByGLs
	HNP//a10OnaxsQEyna6MCDE9K/Fy7tj2UaUmvLcTtIhPwEHNyTwmg3WeCHIPCgLpBK1buM1r+mS
	5VhD7j7P1uQOnzo4J3t1YeAROLoCGLmGmALDQT7gScOhgNclo8DS4A6ZA7mW/uPD2vA==
X-Received: by 2002:aa7:ce15:: with SMTP id d21mr7030947edv.276.1555797859954;
        Sat, 20 Apr 2019 15:04:19 -0700 (PDT)
X-Received: by 2002:aa7:ce15:: with SMTP id d21mr7030924edv.276.1555797859091;
        Sat, 20 Apr 2019 15:04:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555797859; cv=none;
        d=google.com; s=arc-20160816;
        b=qmR5QrdAlB2LKDmBYMJeCcSue2dOWSxdtVpu5j5ZJbMwWKRww9U3CiQ3Fmh8cnK32A
         bcYk8cy/HWchuPVgHnsVOUTqn5Sl2WrFPkajaSZoIr4cDdbAxqGAsfI0H9FTIzrjl0MD
         JGXEsEDcWTB7eVkvehZJAz54uxenWc2i/yxILF2gvZgr0mYA8fSl2de8kgvL+fhSJqXF
         lsmhpFD94NksLwwO2i6xx2TS0Oi6RMzncjliamXsQ8SliwNeOQ5lcsmEUHiDWNYavtFC
         mCte9oSaDiJv2uQdEHKlt8ZsgX6QTrv/91JPKbyQZrlA6n7aBmZkSUKyZqhVV8h8o81N
         3hGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ldGakbeMe/Lt2zN3VzkUpoUzBgNiYR8VYYlH08lu4Jo=;
        b=rfe6/EDecDd12b7ZagQoTrZBVREhLWN3QJ2KshWNBh95N/WzwYgrFaPjMMhiojrGnw
         iuQ3iifaVKYJzGvdxks/gihNduwQP1zVNy4foQVAkvn/76CeqwpETRI1oG6o0tqQPNag
         rNkKORgiiRCXco1vesfpxTOSawwlpGlPVmKxGCdpYUm0DaA5U0K5pfxB78piwwb2Nz1h
         3ArA4tdCrLEaivp8N/xc+Bb/edJvUdeblYKTBzb4WbnLo3/f1iUObOtDVL+dcj6ZYq+8
         3HMk69A38pBHPafu9uAfLcPOsj3aGLqUcd/w1UYXfM+x8ZyHBVb1ZOGACUxmSo21dXtX
         pJNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=ORWiaI+Y;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w49sor64694edb.21.2019.04.20.15.04.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 15:04:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=ORWiaI+Y;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ldGakbeMe/Lt2zN3VzkUpoUzBgNiYR8VYYlH08lu4Jo=;
        b=ORWiaI+Ytll5EGAnzlMifemWhfONQL/8msZPZ/t4GAzbqUTRWL+AGGqRfzgLwXLiYy
         oHPdYzxjUpBtlRyjdQ530CpJDKKxaFyJBULeP4lDTl/wRK2XTLS7qR723rh74zQfIW/H
         ixP6H8jBuseWGRJWSt9MLpIqcCLqqMlpQCwmj+m4zBngIq+hM4igY4AdKlnJr6VxDtOr
         l3EaYq85sBwm3KKumaNJ1bgvLqehaU1VZ/ST0dovMxskHTSocMIyzkONaiX21+kmXy9w
         yXQnYu9JZpgDAj/jILsEWEOupBZywML2kC+4becYHw526Xv2UrS8FYD9Xc3BgNTsbuve
         hOaQ==
X-Google-Smtp-Source: APXvYqzJsP/uUBOTa8F60H6DOWHPR7LdNkf2eeXWxOZiwVI9vC4YfgDXBWK2g4ZV7P0lur0pLJWVe3HVjkyAGGl/u7c=
X-Received: by 2002:aa7:cf8f:: with SMTP id z15mr4002141edx.190.1555797858736;
 Sat, 20 Apr 2019 15:04:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190420153148.21548-1-pasha.tatashin@soleen.com>
 <20190420153148.21548-3-pasha.tatashin@soleen.com> <CAPcyv4j9sG6Wy3EfTuPb0uZ2qp=gr9UgUhpnXQA_g6Ko9KFmLA@mail.gmail.com>
 <CA+CK2bA2QTzZtFvGRMaG10_TretDr6CGgZc4Hyi_1pku4ECqXw@mail.gmail.com>
 <CAPcyv4jrxMNEEeUZZG3=CdkYSyX7OtJLv_ZQ1gbML7bscePiQA@mail.gmail.com>
 <CA+CK2bA-wDwRT5Gv2p9Nm1Vr8LNg84rQdE6=s2m2hQLYqj5Rog@mail.gmail.com> <CAPcyv4gBu5QhgRQ+maJs108JwBrcCa9U1e9wgO8FP6Q3qwy69g@mail.gmail.com>
In-Reply-To: <CAPcyv4gBu5QhgRQ+maJs108JwBrcCa9U1e9wgO8FP6Q3qwy69g@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Sat, 20 Apr 2019 18:04:07 -0400
Message-ID: <CA+CK2bBFqq0tNOE9gh7JAhjw8XLW_pMpVQtUwbm6JwW=LWt_iQ@mail.gmail.com>
Subject: Re: [v1 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Dan Williams <dan.j.williams@intel.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 20, 2019 at 5:02 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Sat, Apr 20, 2019 at 10:02 AM Pavel Tatashin
> <pasha.tatashin@soleen.com> wrote:
> >
> > > > Thank you for looking at this.  Are you saying, that if drv.remove()
> > > > returns a failure it is simply ignored, and unbind proceeds?
> > >
> > > Yeah, that's the problem. I've looked at making unbind able to fail,
> > > but that can lead to general bad behavior in device-drivers. I.e. why
> > > spend time unwinding allocated resources when the driver can simply
> > > fail unbind? About the best a driver can do is make unbind wait on
> > > some event, but any return results in device-unbind.
> >
> > Hm, just tested, and it is indeed so.
> >
> > I see the following options:
> >
> > 1. Move hot remove code to some other interface, that can fail. Not
> > sure what that would be, but outside of unbind/remove_id. Any
> > suggestion?
> > 2. Option two is don't attept to offline memory in unbind. Do
> > hot-remove memory in unbind if every section is already offlined.
> > Basically, do a walk through memblocks, and if every section is
> > offlined, also do the cleanup.
>
> I think something like option-2 could work just as long as the user is
> ok with failure and prepared to handle it. It's already the case that
> the request_region() in kmem permanently prevents the memory range
> from being reused by any other driver. So if the hot-unplug fails it
> could skip the corresponding release_region() and effectively it's the
> same as what we have now in terms of reuse protection. In your flow if
> the memory remove failed then the conversion attempt from devdax to
> raw mode would also fail and presumably you could fall back to doing a
> full reboot / rebuild of the application state?

With option two, where we will simply check that every memory_block is
offlined, we will have deterministic behavior:

1. If user did not offline every dax memory section beforehand via
echo offline > /sys/devices/system/memory/memoryN/state

echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
Will be the same as now, will simply return, and user won't be able to
use dax afterwords or hotremove it.

2. If user did offline ever dax memory section beforehand
echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
Will be guaranteed to succeed to hotremove the memory, as there is
nothing that can fail.

So, if user wants to hotremove dax memory, he/she must ensure that
every section is offlined before unbinding.

Pasha

