Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6BE9C31E5D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:18:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6A4B2085A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:18:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6A4B2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 426118E0005; Tue, 18 Jun 2019 05:18:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D6648E0001; Tue, 18 Jun 2019 05:18:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 276BE8E0005; Tue, 18 Jun 2019 05:18:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C90AD8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:18:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k15so20435888eda.6
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:18:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ck9DfEr1n1N/xliLuAp5O1tFJRzPEHxxJLOoLA3be3A=;
        b=acCJfoHCzPI7710JZ/LQBRX2FGZicyahSPyw1y1UPwjCYZ52jRkFETZg4wqqVd56ms
         t7+jzYwy9Wka64+Xa19ZEbRuYf3O5zF+GSeogJk0YiEJvgsxW5nsuQzRaAOs+XklwRZ5
         lKnvgvs+XXPiR/62Y64PxtTUV01od7z+FbIt7+9Z6ovY8uHSGabNExtwGLbwb4VUeGAR
         yLpBdPZyVTwtVrNBJlM0fQWYvWBCDV8JM6aBjc2hLmQGCXe6W3CmswMtVA+fsnsW2OQq
         WMZT/kFpLFRNJ23DWJX0a3rdg/Bzn2awO7miKFgkFfs8k1Z3pa8yZ+gXjNUfGw/Bi+qz
         71Lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAWP/83WdRMixG9As/3q99IC33teIgEi1+0TcLkXp/Pl0KChDpMK
	7Ch668z/KQu7fQCRb5niSpvXJkaGqqIxFqd3Ac5bcGYWUNsILOsztn8vsTZK0gHl6OnbHPJJjYa
	w3WWhZd5dO3UVUPEbSd+AkpHzoGGHUlESd0khHnR3RbJZJ7YeUygRmX4nAstNu+/V9A==
X-Received: by 2002:a50:8a85:: with SMTP id j5mr74625743edj.304.1560849500387;
        Tue, 18 Jun 2019 02:18:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzT3RHCdZv4DFsA46Z7YPMzcsevD9VZZXFF5KAArYXWDxQE6Ar/2fSQKecIdHTs9tttrbd6
X-Received: by 2002:a50:8a85:: with SMTP id j5mr74625694edj.304.1560849499692;
        Tue, 18 Jun 2019 02:18:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560849499; cv=none;
        d=google.com; s=arc-20160816;
        b=Wbu70T3llz7j1508syodFarCvddXfl0ZnhvKhZb7bs9Wpt4oLlTmcAlNQi4bvKQdjL
         DeY1BYsgrs2K8taAG9Jld7su6DuOpGs1UoNhoQ+xbyELRsTTgfyhlATFL9aOJJmcraaz
         pwszpVxWP5y95oejjbRIF9wavElJ7Sd1QaJw4wtEFGypE9WtzxDj1KbQufwhfwrYz2rK
         frydtGJ8loIqX0rHOJgJzbr8xSGPzlD2G4/EO0XusfBevI/hoA9ES8ExRdygH6xn8qAw
         IIZUpaJCu/ggZH0JJLdI1671tWUVHulGVn1ZhVejmIh5vN0SrZiHDNm5Yj9uz4AMlUrd
         2v3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ck9DfEr1n1N/xliLuAp5O1tFJRzPEHxxJLOoLA3be3A=;
        b=LPejtdElhJGlWUnzOw3YZVW9omBVHwMer+KpiUAmF7tJnl46UItUjzY23H5ISqlrQ+
         0LbcTZ6iLgIgbpQb3Zxu5sWgW7+ynmL64cPHhmyUB0ku+6HIGOO1Jam562zS4AElnNLB
         VIHTTheCYJISjfEq71zmlMkCGkUxUNNRFnqFTUeoBJkhbXO/q1TycXeQ4YWtY86v0Jbx
         caYOp1gy3ZhfmIb0x5lJktiVFHnLCRjmRntdk6G9Kq0BPVlQbzAfqs88GVpuiNqZ+9T+
         woK9uSfjwobiqfSXtxm8XEirE9ca3NSvi9ZIv5bkF+lfylCO3fYlx9jHadXKqyFmdy1h
         mX2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e12si8493267ejj.177.2019.06.18.02.18.19
        for <linux-mm@kvack.org>;
        Tue, 18 Jun 2019 02:18:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D19DC344;
	Tue, 18 Jun 2019 02:18:18 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2BBBB3F246;
	Tue, 18 Jun 2019 02:18:14 -0700 (PDT)
Date: Tue, 18 Jun 2019 10:18:12 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Kees Cook <keescook@chromium.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Christian Koenig <Christian.Koenig@amd.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, Lee Smith <Lee.Smith@arm.com>,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <20190618091811.GC2790@e103592.cambridge.arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <20190613110235.GW28398@e103592.cambridge.arm.com>
 <20190613152632.GT28951@C02TF0J2HF1T.local>
 <201906132209.FC65A3C771@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201906132209.FC65A3C771@keescook>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 10:13:54PM -0700, Kees Cook wrote:
> On Thu, Jun 13, 2019 at 04:26:32PM +0100, Catalin Marinas wrote:
> > On Thu, Jun 13, 2019 at 12:02:35PM +0100, Dave P Martin wrote:
> > > On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> > > > +static int zero;
> > > > +static int one = 1;
> > > 
> > > !!!
> > > 
> > > And these can't even be const without a cast.  Yuk.
> > > 
> > > (Not your fault though, but it would be nice to have a proc_dobool() to
> > > avoid this.)
> > 
> > I had the same reaction. Maybe for another patch sanitising this pattern
> > across the kernel.
> 
> That's actually already happening (via -mm tree last I looked). tl;dr:
> it ends up using a cast hidden in a macro. It's in linux-next already
> along with a checkpatch.pl addition to yell about doing what's being
> done here. ;)
> 
> https://lore.kernel.org/lkml/20190430180111.10688-1-mcroce@redhat.com/#r

Hmmm, that is marginally less bad.

Ideally we'd have a union in there, not just a bunch of void *.  I may
look at that someday...

Cheers
---Dave

