Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5841FC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 05:45:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CCE82087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 05:45:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="PR2k4Xk2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CCE82087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3791A8E0002; Thu, 31 Jan 2019 00:45:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 327D08E0001; Thu, 31 Jan 2019 00:45:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23F4B8E0002; Thu, 31 Jan 2019 00:45:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id EAFDA8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:44:59 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id v184so1016706oie.6
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 21:44:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=aVfDndj6VBemYhBkReB2Uec5tndDqGkXjCOoMo2dZuw=;
        b=rdBsiAD4wmSgrTTvItnxxn3XKu7IAzEZo6Wm5vavkgTGfGfJnoj1kify1afblrsFHh
         OonGrKFQvm3fB8f9adhC/86Lpj/ODqnJ8INYBBRS1VvnNPuSsoFap7s71oMQcA3iELMo
         RK18SznC4RGDcTqRGK3diEKnfiFrt7cEEpLd9T8ju3R/YKwfoAiIv3567sAubWERvy+X
         kHdhCrb0lG3Q/8ZcSusUyO+6LxeIpd9V5fkfmr02/Cp1fRH1Xh3xgeUSoA+4sN0OULHk
         pzIvrgpac2a1Q+HMLEttqEx6SlpOlnzetOhFn2jCkViQZIhNhJL4iK2dBsz1MRqlX1X6
         /EGA==
X-Gm-Message-State: AJcUukcdBQXmJliknSXtcHIF0WTzoN82PcZNoiB2qwfzGO1Ej5nOZ8YF
	7X+R4MISbRbpjkiX9eWHV5InF3n3M/wYDk7jpi99XPqxX7m1FwfDT6fsuvzpk18S8zDOF1VCHhX
	YAl6eVMRei8wi5x3cK5lvCaFTVl6p3q2DZrZeBOVHR9K0Fc2wsWoNy+2BCxOytE1KJj4Rx04C7D
	N3cNN/L0WNq6dhJ6icrejFvtCMvhdDsr6xU5/eW38TSArErDDZZ1kg1aZX4nXXHRn4+KE6DvGUW
	drGjzcWwl2MHwY+97onDrVJZ1e399F+uA3GZXjDe0M7o9m2yOSYs3oio5LGPFMxFot/7rkWDBUt
	HllSFWZ/hB9bvzVrpmNa8hfbRNplw01qsZHfrkbn9GxoFxwv0Z8zyonAkvUHb/aeNr/ThaW52PW
	x
X-Received: by 2002:a9d:5a81:: with SMTP id w1mr25839685oth.317.1548913499556;
        Wed, 30 Jan 2019 21:44:59 -0800 (PST)
X-Received: by 2002:a9d:5a81:: with SMTP id w1mr25839647oth.317.1548913498603;
        Wed, 30 Jan 2019 21:44:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548913498; cv=none;
        d=google.com; s=arc-20160816;
        b=xAakGziXkBOwooFwzPQexwbg9u6Mz/ZORc9kwbyh7LH6+Y7qGSQnB/zhk6AQka4jbr
         JTybD9FV6p9vg/OuSjuwzXz6tjY8rEWj6mz3JmGJBKvwEhZ60LhcvKKohbHbpebHboxd
         ECkXbsEMy2R3ZVvoif9Yb95TG6G5Qndy4kkm3wsjGY7zX7zeaXpKxVFie/k3l2B2WamC
         KywWibzNy11rqxXDqfEveoXTOjPGwPtXWsvVDb1WEJs6pCkq6iOh2c6rGw8jBa9I2abe
         QwStZ9kzv/uTtPuqcu+P6sdLM8Mw+v9VllnrKOX+WbwQkYj3r+0Jxl+xj6GHrDDOqVvT
         zFrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=aVfDndj6VBemYhBkReB2Uec5tndDqGkXjCOoMo2dZuw=;
        b=wDtyIKJcx9+7ttrLMoRISficpS5CTGCXWUdminWoKEsPZ4kWW498YU1RiOU8ZGM4hh
         uHI2XEKA6VPTw0fa0wecV6Ed4EEl5Gw2c5t/Fpn50SeBX9pap5zI1p2tBlBcFSKUXobQ
         b7aM6SDUPKFR4JZWWK1JMnSKVyrFBfL81Cd1IWh9dMmRFDc582EzM1BeCPTwlPjVDbB/
         uN7KW2tjxphom0EHubJuxhJIrWk0WH3kl1MZoOgnheW0WHuLRTuYLMUfzrYqG9FfU9D4
         WpTEn8DiXlpbmWTKBEQO1AYTRkc8cZYJekGzOnuQBXWDNkoAwQRvarmU76q+PXKRKXXj
         vOIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=PR2k4Xk2;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c126sor1751529oif.162.2019.01.30.21.44.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 21:44:58 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=PR2k4Xk2;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=aVfDndj6VBemYhBkReB2Uec5tndDqGkXjCOoMo2dZuw=;
        b=PR2k4Xk24Uu0hY9vI11raPfjPlpQR/1DbwvGdcqc9Ji235UUD02vPNRnnfbV1ewGqF
         pfG2x7fyuQRyAG/KlFrk3UuVA7jEWPvGuLSqm94wBx5OoWlt8fmSQmVb7S5LLVt+zq+M
         yPq+uhM4RNb25S7qyojwqQoY7ITU/TeEUiZOKtMAvz7XxaD0XXbYRa56bEdMbrxbQqug
         6VU1aC0ec7ydUH4LONZmN+L9aXCqBYOZ32eAZEzdtmyXGm3nmGkgTZbhrsGFKwnLhT6W
         qK9MEuI5gu1iYroCBKq/4y2slXff32YcFTpmCJNlgMeyazl+lkCTbB8E2/IVNIA81QVC
         DouQ==
X-Google-Smtp-Source: AHgI3IbT1tV5Ek4hn71MgwttuV/sQt+vNX3jhl11o5tP1/xzowAV9Sz3tedqeKSjtRCjW8TBufjcOWZ+uGIbDEQGz0g=
X-Received: by 2002:aca:f4c2:: with SMTP id s185mr14845265oih.244.1548913498259;
 Wed, 30 Jan 2019 21:44:58 -0800 (PST)
MIME-Version: 1.0
References: <20190129165428.3931-10-jglisse@redhat.com> <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
 <20190129193123.GF3176@redhat.com> <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
 <20190129212150.GP3176@redhat.com> <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com> <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com> <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com>
In-Reply-To: <20190131041641.GK5061@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 30 Jan 2019 21:44:46 -0800
Message-ID: <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
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

On Wed, Jan 30, 2019 at 8:17 PM Jerome Glisse <jglisse@redhat.com> wrote:
> On Wed, Jan 30, 2019 at 07:28:12PM -0800, Dan Williams wrote:
[..]
> > > Again HMM API can evolve, i am happy to help with any such change, given
> > > it provides benefit to either mm or device driver (ie changing the HMM
> > > just for the sake of changing the HMM API would not make much sense to
> > > me).
> > >
> > > So if after converting driver A, B and C we see that it would be nicer
> > > to change HMM in someway then i will definitly do that and this patchset
> > > is a testimony of that. Converting ODP to use HMM is easier after this
> > > patchset and this patchset changes the HMM API. I will be updating the
> > > nouveau driver to the new API and use the new API for the other driver
> > > patchset i am working on.
> > >
> > > If i bump again into something that would be better done any differently
> > > i will definitly change the HMM API and update all upstream driver
> > > accordingly.
> > >
> > > I am a strong believer in full freedom for internal kernel API changes
> > > and my intention have always been to help and facilitate such process.
> > > I am sorry this was unclear to any body :( and i am hopping that this
> > > email make my intention clear.''
> >
> > A simple way to ensure that out-of-tree consumers don't come beat us
> > up over a backwards incompatible HMM change is to mark all the exports
> > with _GPL. I'm not requiring that, the devm_memremap_pages() fight was
> > hard enough, but the pace of new exports vs arrival of consumers for
> > those exports has me worried that this arrangement will fall over at
> > some point.
>
> I was reluctant with the devm_memremap_pages() GPL changes because i
> think we should not change symbol export after an initial choice have
> been made on those.
>
> I don't think GPL or non GPL export change one bit in respect to out
> of tree user. They know they can not make any legitimate regression
> claim, nor should we care. So i fail to see how GPL export would make
> it any different.

It does matter. It's a perennial fight. For a recent example see the
discussion around: "x86/fpu: Don't export __kernel_fpu_{begin,end}()".
If you're not sure you can keep an api trivially stable it should have
a GPL export to minimize the exposure surface of out-of-tree users
that might grow attached to it.

>
> > Another way to help allay these worries is commit to no new exports
> > without in-tree users. In general, that should go without saying for
> > any core changes for new or future hardware.
>
> I always intend to have an upstream user the issue is that the device
> driver tree and the mm tree move a different pace and there is always
> a chicken and egg problem. I do not think Andrew wants to have to
> merge driver patches through its tree, nor Linus want to have to merge
> drivers and mm trees in specific order. So it is easier to introduce
> mm change in one release and driver change in the next. This is what
> i am doing with ODP. Adding things necessary in 5.1 and working with
> Mellanox to have the ODP HMM patch fully tested and ready to go in
> 5.2 (the patch is available today and Mellanox have begin testing it
> AFAIK). So this is the guideline i will be following. Post mm bits
> with driver patches, push to merge mm bits one release and have the
> driver bits in the next. I do hope this sound fine to everyone.

The track record to date has not been "merge HMM patch in one release
and merge the driver updates the next". If that is the plan going
forward that's great, and I do appreciate that this set came with
driver changes, and maintain hope the existing exports don't go
user-less for too much longer.

> It is also easier for the driver folks as then they do not need to
> have a special tree just to test my changes. They can integrate it
> in their regular workflow ie merge the new kernel release in their
> tree and then start pilling up changes to their driver for the next
> kernel release.

Everyone agrees that coordinating cross-tree updates is hard, but it's
managaeble. HMM as far I can see is taking an unprecedented approach
to early merging of core infrastructure.

