Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79482C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 23:14:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B8B02133D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 23:14:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B8B02133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8534F8E0003; Thu, 28 Feb 2019 18:14:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 802BA8E0001; Thu, 28 Feb 2019 18:14:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F19A8E0003; Thu, 28 Feb 2019 18:14:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FCDD8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 18:14:43 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a5so17339031pfn.2
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 15:14:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kvT0SRU/eDlTI5wh6qb6Ua4Yl1HMbI7w+MQOLLFa7BM=;
        b=ZlTsR+tphPGf9aUScSALoYcPaqa4T/jcu4FrGFlOEM5ga94yb3em2VNGTJljYl/nRz
         yx4waIsV4k1z0xdGnk314UWUiLHr/zG+5PlIDlIHk4G3C9qmWJ4ybjg57gM8/N6Ebw2p
         QxhtAmkYFGIkMaw/j6B+kJevw3DHutuzwjqqNBQcSxMN4RJ3iheK3J2SwdMb4fQtnCT9
         dpOaRjhEfWCo4QjU+r1+EnPoOl7agWUpLzQzYqqV1i8CPLGQDVWUlvnRr2LQcHsv55oi
         zmEmSE+/2TbdAEct7ZQMv/cvsroaQsSU+jDXv3pMDrNaLgk6tceUPck5ZWJoNdA0gLjN
         BPhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAW8nBCT4HDRd2hpuOmWK9iDBtDHooY9VAHiPsI4YozofdJzwTlB
	qUiXCVIFm1VKxu28aaIDI+zXQtyk4MNnEIHcOI+12SwOD/9z6UitM3KD1C2YOY4zNu4mzPhKnOt
	qdw4GE/wfl2GWnt3YTNqBHFJ1eCQ5+oALvFu8NKMsxIGsKkp+3sc4kf/SLl4XN0om2g==
X-Received: by 2002:a63:9dc3:: with SMTP id i186mr1653651pgd.305.1551395682786;
        Thu, 28 Feb 2019 15:14:42 -0800 (PST)
X-Google-Smtp-Source: APXvYqzpR5El8Oyl9wQsCU9SdMvLWOeLDYAVkGv6WlKHaM4/fdHuzlbbiRTHPY5+UTTj6SRTAAtl
X-Received: by 2002:a63:9dc3:: with SMTP id i186mr1653553pgd.305.1551395681226;
        Thu, 28 Feb 2019 15:14:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551395681; cv=none;
        d=google.com; s=arc-20160816;
        b=BVv4R7HPgHgEKS9jnHMU/v58xjtLxp+htumqAQUHfWdW1TiBBKXbVHxMqW+xI4QYge
         tf7j/Ed6J3uWreRJrhBvKn6BrRa/E7lo5Uizb6Wlhu+FK2Wz2PUTh+ZGWsSov1J7SJ/g
         Uaui6LznKq333lX9VEJTXsQiaDOv7lW26Vk77KyESbGy1avsvDsgal7Cvj9NSPPSZvcg
         B4v/JOe/OjL9hRJmceQ1Eh0Ma3CaKr/KzmDbaViks/M2782M4a51XXjO5iBC9mOHUlE8
         P40ZtweqOZeG+TVNCLjdKCo0vsDN2gt2KHm/9xL+Y4HJ/mJs5XQM86sBxA57i83eVxTM
         6Cug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=kvT0SRU/eDlTI5wh6qb6Ua4Yl1HMbI7w+MQOLLFa7BM=;
        b=yUOCdgJ7hPJfmz40xV1k2bNZstmVxr0I9kMYCMIWqozsBWj4zHAXQeLoHyJczv9gwK
         GBrXecSlXLnIaZbZZfxB+IgD6I3SdrFwsPrvBA/dkNeDWKtDC9YPg6WsGZyxnpio+T6g
         TX3nk+wwMbEa5W0udWmXElbXeE3RV+GBS/gXEBtWgHofNvnhch6WYE85gp7W+EKa4EIk
         z5x8uXrJ8aPbldELriZtt7/BctGnFIrLlUrzeBTXBBx+R/J3bH57yf+gUAEVcR3G+Dk2
         EzWhOvcw7nn9Kme52e2Lj51kXygualc5AzYxQPJlsFMrFvvMw4AuaAGZtF2kb5tkltZP
         fLdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n14si5705776pgv.520.2019.02.28.15.14.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 15:14:41 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id CFEA0A94E;
	Thu, 28 Feb 2019 23:14:39 +0000 (UTC)
Date: Thu, 28 Feb 2019 15:14:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Mark Brown <broonie@kernel.org>, "kernelci.org bot" <bot@kernelci.org>,
 Tomeu Vizoso <tomeu.vizoso@collabora.com>, guillaume.tucker@collabora.com,
 matthew.hart@linaro.org, Stephen Rothwell <sfr@canb.auug.org.au>,
 khilman@baylibre.com, enric.balletbo@collabora.com, Nicholas Piggin
 <npiggin@gmail.com>, Dominik Brodowski <linux@dominikbrodowski.net>,
 Masahiro Yamada <yamada.masahiro@socionext.com>, Kees Cook
 <keescook@chromium.org>, Adrian Reber <adrian@lisas.de>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, Johannes Weiner
 <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>, Michal Hocko <mhocko@suse.com>, Richard
 Guy Briggs <rgb@redhat.com>, "Peter Zijlstra (Intel)"
 <peterz@infradead.org>, info@kernelci.org
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
Message-Id: <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
In-Reply-To: <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
	<20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
	<20190215185151.GG7897@sirena.org.uk>
	<20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
	<CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2019 16:04:04 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> On Tue, Feb 26, 2019 at 4:00 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Fri, 15 Feb 2019 18:51:51 +0000 Mark Brown <broonie@kernel.org> wrote:
> >
> > > On Fri, Feb 15, 2019 at 10:43:25AM -0800, Andrew Morton wrote:
> > > > On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kernelci.org> wrote:
> > >
> > > > >   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
> > > > >   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
> > > > >   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html
> > >
> > > > Thanks.
> > >
> > > > But what actually went wrong?  Kernel doesn't boot?
> > >
> > > The linked logs show the kernel dying early in boot before the console
> > > comes up so yeah.  There should be kernel output at the bottom of the
> > > logs.
> >
> > I assume Dan is distracted - I'll keep this patchset on hold until we
> > can get to the bottom of this.
> 
> Michal had asked if the free space accounting fix up addressed this
> boot regression? I was awaiting word on that.

hm, does bot@kernelci.org actually read emails?  Let's try info@ as well..

Is it possible to determine whether this regression is still present in
current linux-next?

> I assume you're not willing to entertain a "depends
> NOT_THIS_ARM_BOARD" hack in the meantime?

We'd probably never be able to remove it.  And we don't know whether
other systems might be affected.

