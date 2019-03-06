Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E71F1C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:08:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B6872064A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:08:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CeX5v9ww"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B6872064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38F918E0006; Wed,  6 Mar 2019 14:08:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33DBD8E0002; Wed,  6 Mar 2019 14:08:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 253D98E0006; Wed,  6 Mar 2019 14:08:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id F10AA8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:08:51 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id q192so6330693itb.9
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:08:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=R3hq+LqjUjg+BkrZdYl/kSPNrNKGY5hWXHfQfAinw+s=;
        b=SPh80agb2ik53Xwzs+ZEZepRd9rSVx9WNVSVIPwdoJd4HisGeZfyiSIctfYJwpp56Y
         +wQi3GeREXbz98oifxC55df/kayVYwz/bgxmD2Qmzb8kEcaR8BTki8bAFu6iegwoJ1bX
         OWgh9klCF37DVtkp7bfJMCJn2MvOOxR3BmxaUwfGqaFEjgeWwixyl4DkZ/nK2U7nZc8z
         Fgu3OEaNQ7PoBKMPXjNQO+AxhqxdpUBZ+FQDers6bqBmp5A2ZW44uTp1CRw6R8bme4VB
         nGDcRTAT4vIzQLqiI3il4QrHlm7+8I6eKOowBjGnBy+ubpZcKkbE7/9cPwPcn8TcwT+E
         +O2Q==
X-Gm-Message-State: APjAAAXcP8X6C3iI7+6F4IPaRcglVp8rLNj4RhjlIMxmxBVzdWM/6eF6
	zr61Jtl3yFlKOiuNx8CnNm3FbOVVzrCQaGCSjacJd4b0li2LyDJl9e5K0iDXyCtBSY3YpSiEvlG
	HJ7F1IIkEoD1rK+tYsjRXYbY6UGLxmwQ74CpETw+sRaJjQ6AoTgYiB6ipNVtO4eOl3u32aFUTk9
	WRcdZbI0u6DRNuFvlJlvdq9yzafXoEQ7B3PiqtxobdggRMxsw15Fwf51D1X8f8kjmCW9cv7in9p
	lvOwou4DN/Bfdz3h/aHmCwzLoSPyF67G6KLGNmp6Jg3Za4jz4128KEVlDJY77XjCWBGr7+gweYn
	ANLB3ssFGd2fT78ZWD0fFTkSPw/hqb/ak5FcciLa/JdIjaQkGUcmgqrtZv8AJaArkydfU8tKrPK
	Z
X-Received: by 2002:a02:8899:: with SMTP id n25mr5443260jaj.7.1551899331743;
        Wed, 06 Mar 2019 11:08:51 -0800 (PST)
X-Received: by 2002:a02:8899:: with SMTP id n25mr5443219jaj.7.1551899330975;
        Wed, 06 Mar 2019 11:08:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551899330; cv=none;
        d=google.com; s=arc-20160816;
        b=g6G/MLieGa9pXbRz5KKhXF7vCSg0E1f1/FNIbLRDhvL0YOCp3tt/KT1doJ2+kV9dIQ
         oo6vwVhSPFBFKlbFTay7lY2YMzW7tepXihQXTgl7juXHLW0rFd6iDXdFbK/qfN9trVHm
         HxdPPj7ThetPEwCNXNwdO7Ggrgg9XdqFbBA7xhh1885xOKPg4xPzh8693hjZNdeqHHcu
         PVppVShziN1Z2eiZvQQnM62NWDPe5345dyvVbyusG90BJNvCOrJa6FF8y/dimN5uJnHc
         IUZP9Ul2NDbccvs7UQKd/bwtn82FPcPFjEo+IKov24qrs8YfV//pDSVImE2CCdfAQAA+
         GEJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=R3hq+LqjUjg+BkrZdYl/kSPNrNKGY5hWXHfQfAinw+s=;
        b=IkfKQ90b14DEb2ZJH8aZ7Dp+VxEi+cUdq2bAV9VWyBXdkfo2mdQ2bbV+9Kg1tNAX2H
         wQNOaNNfHLLb/fvFmZv9vc75XDCfk6Y0kaak9Dy9FAtzzHTE9etcwkNn2ceRIrZWYhSQ
         rUzjoXxnPyCoeoE6nNJPo5dazl822KMF58x0jzChl0q7fsyhbTwMdgZg37QCyL18jWOG
         odGwVoHEz8beCf5EhhIw+YFM11mJtwSLkV+9FnnFjAxXIIHDs5VQ7yQyTmaQUOp1V/zr
         2Kg+HppTy8t8UQUmzMthxY5ZoX+99Y9ZGaa9mmuipDAhL40hD7Zer3Fu9PzuQg8yxrvG
         YLcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CeX5v9ww;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a184sor4356342itc.31.2019.03.06.11.08.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 11:08:50 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CeX5v9ww;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=R3hq+LqjUjg+BkrZdYl/kSPNrNKGY5hWXHfQfAinw+s=;
        b=CeX5v9ww2mf+7Asj0FqY8Z4jtCmK1Az5A+PyiA/ulDFEfbMzzwOds93LrLJTv0ot+i
         qB/dcZbpf5eUt6PTI5Rc5qHOqAcHPwt5Wzl3nub0iQkXESwEW60W1bRH6IDTjPUfnKN+
         AWeTZ+8hYDDujKbwHsAIJQf4KDakpoFrLCAdHkhtKc99/kH0MG7n+azO0P+F5XE5XRFC
         Nxhjow2KSEEgfHHoC85lHH3f3EiOPwNdY/1kme9assbm+/ooyLhAM/3iIW/xIJKFUkSv
         lPSYORcfT8R7Im4y2zvhze04ZNnL57pxeT76vQCqoQzY8jVDC4S7XfwA/TnCQv4y4lso
         wFmw==
X-Google-Smtp-Source: APXvYqxre7Qg17324YiENSBsRaXlZ6Rfn+CG+w7EfQ5MaSivgqBjvVpp+bYxyY75ucNZl1jKG7zxvlLdP6gr2uHKHSY=
X-Received: by 2002:a24:4650:: with SMTP id j77mr2992351itb.6.1551899330458;
 Wed, 06 Mar 2019 11:08:50 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com> <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com> <20190306133826-mutt-send-email-mst@kernel.org>
 <3f87916d-8d18-013c-8988-9eb516c9cd2e@redhat.com>
In-Reply-To: <3f87916d-8d18-013c-8988-9eb516c9cd2e@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 6 Mar 2019 11:08:39 -0800
Message-ID: <CAKgT0UdqCb37VNe7pABBYBXYFrVzYdPntmPf-V6ZYp9DdwmxYA@mail.gmail.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: David Hildenbrand <david@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 11:00 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 06.03.19 19:43, Michael S. Tsirkin wrote:
> > On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:
> >>>> Here are the results:
> >>>>
> >>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with
> >>>> total memory of 15GB and no swap. In each of the guest, memhog is run
> >>>> with 5GB. Post-execution of memhog, Host memory usage is monitored by
> >>>> using Free command.
> >>>>
> >>>> Without Hinting:
> >>>>                  Time of execution    Host used memory
> >>>> Guest 1:        45 seconds            5.4 GB
> >>>> Guest 2:        45 seconds            10 GB
> >>>> Guest 3:        1  minute               15 GB
> >>>>
> >>>> With Hinting:
> >>>>                 Time of execution     Host used memory
> >>>> Guest 1:        49 seconds            2.4 GB
> >>>> Guest 2:        40 seconds            4.3 GB
> >>>> Guest 3:        50 seconds            6.3 GB
> >>> OK so no improvement.
> >> If we are looking in terms of memory we are getting back from the guest,
> >> then there is an improvement. However, if we are looking at the
> >> improvement in terms of time of execution of memhog then yes there is none.
> >
> > Yes but the way I see it you can't overcommit this unused memory
> > since guests can start using it at any time.  You timed it carefully
> > such that this does not happen, but what will cause this timing on real
> > guests?
>
> Whenever you overcommit you will need backup swap. There is no way
> around it. It just makes the probability of you having to go to disk
> less likely.
>
> If you assume that all of your guests will be using all of their memory
> all the time, you don't have to think about overcommiting memory in the
> first place. But this is not what we usually have.

Right, but the general idea is that free page hinting allows us to
avoid having to use the swap if we are hinting the pages as unused.
The general assumption we are working with is that some percentage of
the VMs are unused most of the time so you can share those resources
between multiple VMs and have them free those up normally.

If we can reduce swap usage we can improve overall performance and
that was what I was pointing out with my test. I had also done
something similar to what Nitesh was doing with his original test
where I had launched 8 VMs with 8GB of memory per VM on a system with
32G of RAM and only 4G of swap. In that setup I could keep a couple
VMs busy at a time without issues, and obviously without the patch I
just started to OOM qemu instances and  could only have 4 VMs at a
time running at maximum.

