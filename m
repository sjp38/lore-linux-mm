Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 390C1C282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:28:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE75320989
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:28:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="NHd8Q0gA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE75320989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69EF48E0002; Wed, 30 Jan 2019 22:28:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 625248E0001; Wed, 30 Jan 2019 22:28:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ED6C8E0002; Wed, 30 Jan 2019 22:28:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE158E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:28:27 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id z22so802949oto.11
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:28:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LKR8wCp+72QzShfXC1ccPYHbtEsCxEmpDS1UMRW0uQ4=;
        b=mD7/DfvxDMdcjlqSz+XKjSr+BZfW44x5A+DZTv5DysjihqfnzKyE+PsNwCs4yq+KLU
         Z+VYZz+9Xa9Nl1qTvvawfsSnmhoXb++626Gi/cyxeIK1heBTO/uBhs2af34a+2VW4slY
         NJCNn04/Kmf+5Cln+T+bcpaYwqIqOHz+ITy8gft5KN2chsFitfkhM+qRsfVM74pV8aej
         j2nlPRc/bS6LdB9UG4Cynr9EQ6HptF+XAUJ5wowNEC/trKfYN6oM48uW/GYmJN6Z6cUV
         WlfEMHVKPm4R/wgD7s1QM/VV422490AA51zBL2qAxr/g63ubE6EGcOcm18IrJJkiIfiI
         T6+w==
X-Gm-Message-State: AJcUukfGfFf1LGgYXwQc2K9miCMMRWaXG+YY0sq1DL6Dqqr9v7cDvudP
	E25K82dF1FgZoTUnERkuqUDwN7oBlNdZqCe1PbtMxITFj2XDJIZj0c5nee6jksroiw0VpMW1s2x
	XpkHNicoP6N7QNouTn4KN2gmnKzVq6gzTwwdR0cL6twMGSfPW6Fcy6bnDCHpCafjrp2uS2WuWYq
	+2AaSqGyjPLpFKj4pSAcSPCKEMI99ZFEuc0sw7K7X/UhOw2jjF+THbJgJ4mQpkiTHsawYhjYBqn
	hHmDzOz7x6fMDggLLoGPMcuM2GVZAhimYk6Fjj/lITyxXmpnla5iFkCt24kZSZO6xdP/zB3IwDh
	AbsvXgr1le7x8s5hQbhq941rSiGGxRfNerpFlIh6l3YLTBtJuF9OJyI5MaLf6Te8xO0ucpzAp/4
	6
X-Received: by 2002:a9d:2c46:: with SMTP id f64mr25813834otb.192.1548905306733;
        Wed, 30 Jan 2019 19:28:26 -0800 (PST)
X-Received: by 2002:a9d:2c46:: with SMTP id f64mr25813810otb.192.1548905306020;
        Wed, 30 Jan 2019 19:28:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548905306; cv=none;
        d=google.com; s=arc-20160816;
        b=qkWBHFAv3yiQCquTg18yS2xDkFxPi6WH6a/HJyxSachJvzjv5qDf5MUv+SviuEK0Xt
         3plRL4K3JC2WfwmmiwXQV09N1irkFuXfrnFiSQ/doMiMsGGJ9Ax9X2j+hO+s6S1QhM9a
         OhZGr8Nh/AWGDctlLUIs99xjdOHqB+rtcmlaPZESQ20pHX4M10cCac33SZSM58jcChTZ
         t5UP2UeVrF02bqvwuF5iednmIDDoVqZJIemD77/E3ndMtAV5BWP5lY2R1nHV13ABReIU
         sbXSroutHlcPRrtOtkBBUHkfpwGP4J5GqCNhgsAhpmSzYVGfjS2LNxMB2IfGgWRMgKae
         C6WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LKR8wCp+72QzShfXC1ccPYHbtEsCxEmpDS1UMRW0uQ4=;
        b=gEa24DP1IFrR/V7RoF+K0G2pi6TqD4HegDMhW3mtXq4V2PZ11XioHn3lO34xXdNVrM
         CT28JsZ3OIzS8FrdRF42guO5MCBED5wEuYqK0O8e6Hx7EBCXTydlX2dCJtQTALlM35L9
         pWQA3i/wEwTLaNAZBI5wpHKALjztDMahrgFyL0sHwtsNdEUzauD9Elhq+ASoajpziiw5
         D6paPBHRv2AONHs2fksozee6vAlzscy4l5NpuFIE3JeAXLTHsADuBSRvNI2vwB74m8tZ
         wYQSI6nUryXfP+BOCqtoy6arDTxpdEO6G3ngOndb/R+DNbtyrrdNyDQnUfoX1YNHSwjl
         QxpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=NHd8Q0gA;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t127sor1614893oif.64.2019.01.30.19.28.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 19:28:25 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=NHd8Q0gA;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LKR8wCp+72QzShfXC1ccPYHbtEsCxEmpDS1UMRW0uQ4=;
        b=NHd8Q0gA+XED7qxPiMKJXGVHXZIoZZlQI/QO1qMb0suplz1GTmOybVqFc0dl21ScHZ
         B9W9YkvPx3zI5v1m1a0V3eZZIAfH+72OAkvwHnpwFRSvR3+qU4BKWXQvoU1bb89pPN7z
         oo9ghPe0jEqzJnu+Rx13QI9RiON8jHwrPtYroXNSb691XgB5xJCSYw6bZ4QQPKUWoKvB
         BuCN/tBEhqrIwsWV97Xb/eGd3KSrXuoNHxykRGCTkVGY7GLXtxSjUynuB/Z1x94v1A6G
         Qt5oB00Pq6BzewF96AkF9DbJK2I6TOBmTLmpiDL2bRVP/3P7eHWqR6QmAuKkz4ZcZ8Yd
         RSJA==
X-Google-Smtp-Source: ALg8bN7cjiZrwHF036Im4cVIYRvgSt6s9CiP7Z1vDb0+J9ahKednROx5JuDby2jPMltGGv1GU6huMF/VdL52/MDG0cQ=
X-Received: by 2002:aca:2dc8:: with SMTP id t191mr13551287oit.235.1548905305200;
 Wed, 30 Jan 2019 19:28:25 -0800 (PST)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190129165428.3931-10-jglisse@redhat.com>
 <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
 <20190129193123.GF3176@redhat.com> <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
 <20190129212150.GP3176@redhat.com> <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com> <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com>
In-Reply-To: <20190130183616.GB5061@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 30 Jan 2019 19:28:12 -0800
Message-ID: <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: Jerome Glisse <jglisse@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 10:36 AM Jerome Glisse <jglisse@redhat.com> wrote:
[..]
> > > This
> > > is one of the motivation behind HMM ie have it as an impedence layer
> > > between mm and device drivers so that mm folks do not have to under-
> > > stand every single device driver but only have to understand the
> > > contract HMM has with all device driver that uses it.
> >
> > This gets to heart of my critique of the approach taken with HMM. The
> > above statement is antithetical to
> > Documentation/process/stable-api-nonsense.rst. If HMM is trying to set
> > expectations that device-driver projects can write to a "stable" HMM
> > api then HMM is setting those device-drivers up for failure.
>
> So i am not expressing myself correctly. If someone want to change mm
> in anyway that would affect HMM user, it can and it is welcome too
> (assuming that those change are wanted by the community and motivated
> for good reasons). Here by understanding HMM contract and preserving it
> what i mean is that all you have to do is update the HMM API in anyway
> that deliver the same result to the device driver. So what i means is
> that instead of having to understand each device driver. For instance
> you have HMM provide X so that driver can do Y; then what can be Z a
> replacement for X that allow driver to do Y. The point here is that
> HMM define what Y is and provide X for current kernel mm code. If X
> ever need to change so that core mm can evolve than you can and are
> more than welcome to do it. With HMM Y is defined and you only need to
> figure out how to achieve the same end result for the device driver.
>
> The point is that you do not have to go read each device driver to
> figure out Y.driver_foo, Y.driver_bar, ... you only have HMM that
> define what Y means and is ie this what device driver are trying to
> do.
>
> Obviously here i assume that we do not want to regress features ie
> we want to keep device driver features intact when we modify anything.

The specific concern is HMM attempting to expand the regression
boundary beyond drivers that exist in the kernel. The regression
contract that has priority is the one established for in-tree users.
If an in-tree change to mm semantics is fine for in-tree mm users, but
breaks out of tree users the question to those out of tree users is
"why isn't your use case upstream?". HMM is not that use case in and
of itself.

[..]
> Again HMM API can evolve, i am happy to help with any such change, given
> it provides benefit to either mm or device driver (ie changing the HMM
> just for the sake of changing the HMM API would not make much sense to
> me).
>
> So if after converting driver A, B and C we see that it would be nicer
> to change HMM in someway then i will definitly do that and this patchset
> is a testimony of that. Converting ODP to use HMM is easier after this
> patchset and this patchset changes the HMM API. I will be updating the
> nouveau driver to the new API and use the new API for the other driver
> patchset i am working on.
>
> If i bump again into something that would be better done any differently
> i will definitly change the HMM API and update all upstream driver
> accordingly.
>
> I am a strong believer in full freedom for internal kernel API changes
> and my intention have always been to help and facilitate such process.
> I am sorry this was unclear to any body :( and i am hopping that this
> email make my intention clear.''

A simple way to ensure that out-of-tree consumers don't come beat us
up over a backwards incompatible HMM change is to mark all the exports
with _GPL. I'm not requiring that, the devm_memremap_pages() fight was
hard enough, but the pace of new exports vs arrival of consumers for
those exports has me worried that this arrangement will fall over at
some point.

Another way to help allay these worries is commit to no new exports
without in-tree users. In general, that should go without saying for
any core changes for new or future hardware.

