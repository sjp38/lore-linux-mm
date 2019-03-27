Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C54EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 16:17:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F55A206C0
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 16:17:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="riSZtAb4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F55A206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C11A96B0005; Wed, 27 Mar 2019 12:17:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC21C6B0006; Wed, 27 Mar 2019 12:17:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB18D6B0007; Wed, 27 Mar 2019 12:17:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 78F3D6B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 12:17:50 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id w139so7064229oiw.21
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 09:17:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=o06e9v+9FpXO9GK+yHaRDxnC2XU9MQFMNB9rxnWVCx0=;
        b=LV7MTH1lbsxn3MNtX/yi6teVFRBdheL1UmeHChO0HW5vjRglo9zfDPxc6R/dipSrxS
         zwV+dhIAwGyx7aUdDX0cGB+XLLeMcrzAa2tsb75RdbWBOhZdaPKyLoH9LduRR+HNbTT9
         7Tlkn2YIJQtGbEFOamH96l58p37v2CKhXBm2kO+2Z5hcF081xhJ5ivzC/WB2PZisMLCl
         sX3zCsTC/petRQftvr2SlxRkcpJDtMmTrE1mpvFWj3pUw2vIUDdYFayioYlC8weVenze
         +7XFIw7blnci1apAxSVimapkHcu4W9fdOIsttFxvvZIR1qMTty7d5BUxV9Tf02FqBHt1
         XrRg==
X-Gm-Message-State: APjAAAVzvrl+hS1ZExjTyI72FEETH1l1pKrhmZwPORVkpucBqmFeDKql
	fZrZQpW/Hd8hpPqB8alyIvug4j6TVgmihfmGq2LPGT6zD5C3KQuqARUDmmHLh21tXggzfxavstJ
	uMdiaz1/LZkYtD5DafclNM/q/DyRsu4tzl9IIoZiIdLkooYhO+X4nRxT+h77MExVJWA==
X-Received: by 2002:a05:6830:1494:: with SMTP id s20mr28084036otq.318.1553703470072;
        Wed, 27 Mar 2019 09:17:50 -0700 (PDT)
X-Received: by 2002:a05:6830:1494:: with SMTP id s20mr28083968otq.318.1553703469154;
        Wed, 27 Mar 2019 09:17:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553703469; cv=none;
        d=google.com; s=arc-20160816;
        b=PhFx/FissijOCOQ/M2w0IX+6GoP97l0QSo3GX/q9VW4VAClSkrf8c2rBrCG5E1EfDw
         kOcah0XvtucL37nQ7UBvfQCtxwu+AJyGvaAfb9LUWGidATVxYWgmgMnMsKTmKdd81WKS
         yAw5GPIzuOrz0nPtU7+vYzUc5T7ORg3c6GrLwvCJONYuL0UKmxMLbwEU40jm6mumGSU+
         Mtp96+rDvDNq6q/SvondYfti4FSRSvjabpoPCpi7artKxqwLdzJHqM58dxibG6qQ3VNd
         LxrJs8XY0ARxIscJ6ufMhxdVBdCkFFhF3vMGPR3tbuZD8V5/pmgTacDueXQV8ob/0jRn
         kkOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=o06e9v+9FpXO9GK+yHaRDxnC2XU9MQFMNB9rxnWVCx0=;
        b=xZrIq4CIg5KuLmTgQQXr1gfNYVzqsh/3n14vBa2DEUdrOE/KaMxRycvfEpyz6Z+ADk
         q54Dcz1LmqTfwhexjPD3qyc70wYnqcwBmT3h0jOXzlJBe9MBxtPCr5Yt1F31FzHVbppz
         yRtwsY19pAJBdBDTW4g0weZ0kjnGr0Zv1emIkw4mFDU6VI1nssdqgLfRH+H/Bayvt3lL
         nPBZq4X1CM3pmd/pE1bygTWQiHSU6UIf7YzLjztBQOc0IagZIiXdEsId5qth0wXR76Mq
         xBmHBKw4rKOjQPC4WU+2Z2YfjVTEgjZ6dlGYNGEWfdCDo6LEv1YpZuapCOMlxfdhIbG4
         U4iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=riSZtAb4;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y201sor6209792oie.29.2019.03.27.09.17.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 09:17:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=riSZtAb4;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=o06e9v+9FpXO9GK+yHaRDxnC2XU9MQFMNB9rxnWVCx0=;
        b=riSZtAb4wf4bYiirQclqxvNvoVvIjtdvtpP7hW1LkPvm8AIJkqkLcOikXYp70CGJF8
         pO/VD4mpVZfLCWOoghiHrFHv2ix3uFN93wST3+Zo/8vL8tnAt3RUFcVE+bTNS6b0Bu8S
         sPJHJGMjlaqftIoN/SQpJDjLqgKPHbsLHV7oRhJLaQeY56dthnI7xorlCM3jCS7N1qPf
         4D6ld0NFBKCRMr0LNm2iJAZkUzdSyxX7qhEOV+g9rpVmKKNcFa3531Xk9UPzX6i+LFux
         WYasZ76PTsX5mSzeAOm0mJyw4SL0YYdJEB0FU/+sH9/0HdD1ZHErFmYUisyGtVfwORCb
         wizw==
X-Google-Smtp-Source: APXvYqxG2bnCwdQGUdctD5jNEG+yjmMKiaKayOlZ0HZm5jA1Vxgyy7pJZJpRm6vB9iuirNO+ZditYMBmCo/wZFazHHs=
X-Received: by 2002:aca:f581:: with SMTP id t123mr20220426oih.0.1553703468743;
 Wed, 27 Mar 2019 09:17:48 -0700 (PDT)
MIME-Version: 1.0
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190322180532.GM32418@dhcp22.suse.cz> <CAPcyv4gBGNP95APYaBcsocEa50tQj9b5h__83vgngjq3ouGX_Q@mail.gmail.com>
 <20190325101945.GD9924@dhcp22.suse.cz> <CAPcyv4iJCgu-akJM_O8ZtscqWQt=CU-fvx-ViGYeau-NJufmSQ@mail.gmail.com>
 <20190326080408.GC28406@dhcp22.suse.cz> <CAPcyv4jUeUPwbfToWQtWX1AxfgFLNpBUhm8BvgJ2Hv1RbNPiog@mail.gmail.com>
 <20190327161306.GM11927@dhcp22.suse.cz>
In-Reply-To: <20190327161306.GM11927@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 27 Mar 2019 09:17:37 -0700
Message-ID: <CAPcyv4heVUMUVrFz4HDX11OxW0ZWkS6EpJJ4aT3QJcUmPTFpRg@mail.gmail.com>
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, 
	Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 9:13 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 26-03-19 17:20:41, Dan Williams wrote:
> > On Tue, Mar 26, 2019 at 1:04 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Mon 25-03-19 13:03:47, Dan Williams wrote:
> > > > On Mon, Mar 25, 2019 at 3:20 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > [...]
> > > > > > User-defined memory namespaces have this problem, but 2MB is the
> > > > > > default alignment and is sufficient for most uses.
> > > > >
> > > > > What does prevent users to go and use a larger alignment?
> > > >
> > > > Given that we are living with 64MB granularity on mainstream platforms
> > > > for the foreseeable future, the reason users can't rely on a larger
> > > > alignment to address the issue is that the physical alignment may
> > > > change from one boot to the next.
> > >
> > > I would love to learn more about this inter boot volatility. Could you
> > > expand on that some more? I though that the HW configuration presented
> > > to the OS would be more or less stable unless the underlying HW changes.
> >
> > Even if the configuration is static there can be hardware failures
> > that prevent a DIMM, or a PCI device to be included in the memory map.
> > When that happens the BIOS needs to re-layout the map and the result
> > is not guaranteed to maintain the previous alignment.
> >
> > > > No, you can't just wish hardware / platform firmware won't do this,
> > > > because there are not enough platform resources to give every hardware
> > > > device a guaranteed alignment.
> > >
> > > Guarantee is one part and I can see how nobody wants to give you
> > > something as strong but how often does that happen in the real life?
> >
> > I expect a "rare" event to happen everyday in a data-center fleet.
> > Failure rates tend towards 100% daily occurrence at scale and in this
> > case the kernel has everything it needs to mitigate such an event.
> >
> > Setting aside the success rate of a software-alignment mitigation, the
> > reason I am charging this hill again after a 2 year hiatus is the
> > realization that this problem is wider spread than the original
> > failing scenario. Back in 2017 the problem seemed limited to custom
> > memmap= configurations, and collisions between PMEM and System RAM.
> > Now it is clear that the collisions can happen between PMEM regions
> > and namespaces as well, and the problem spans platforms from multiple
> > vendors. Here is the most recent collision problem:
> > https://github.com/pmem/ndctl/issues/76, from a third-party platform.
> >
> > The fix for that issue uncovered a bug in the padding implementation,
> > and a fix for that bug would result in even more hacks in the nvdimm
> > code for what is a core kernel deficiency. Code review of those
> > changes resulted in changing direction to go after the core
> > deficiency.
>
> This kind of information along with real world examples is exactly what
> you should have added into the cover letter. A previous very vague
> claims were not really convincing or something that can be considered a
> proper justification. Please do realize that people who are not working
> with the affected HW are unlikely to have an idea how serious/relevant
> those problems really are.
>
> People are asking for a smaller memory hotplug granularity for other
> usecases (e.g. memory ballooning into VMs) which are quite dubious to
> be honest and not really worth all the code rework. If we are talking
> about something that can be worked around elsewhere then it is preferred
> because the code base is not in an excellent shape and putting more on
> top is just going to cause more headaches.
>
> I will try to find some time to review this more deeply (no promises
> though because time is hectic and this is not a simple feature). For the
> future, please try harder to write up a proper justification and a
> highlevel design description which tells a bit about all important parts
> of the new scheme.

Fair enough. I've been steeped in this for too long, and should have
taken a wider view to bring reviewers up to speed.

