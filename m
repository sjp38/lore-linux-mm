Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38669C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 18:30:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB39F20811
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 18:30:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Ti6WT1kE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB39F20811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73A936B0006; Mon, 18 Mar 2019 14:30:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E92D6B0007; Mon, 18 Mar 2019 14:30:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B23D6B0008; Mon, 18 Mar 2019 14:30:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 320C96B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 14:30:29 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id s65so2189546oie.7
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 11:30:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sbsTYKGPUf22VNUHUiDumPSMR3YTxTtHfk3y04Q51PI=;
        b=sVgrbUXEvyt7d8O4u08zYVXBhJ4D8mrWlBkOZ/vldkwjvTiiu5uvwHPrT2RX9O/3iO
         ehtblhxLMpPNckwcFVg68/uD1tU00s56PedpdaAy44E4AGghYtu9004aESAiXos5xfLd
         OV/aiNpzLrSgN/wlf/d8ZhYtoBKviYsiR0yvKAl2O0HDNGAhxl/FWPxZHJ92RNMAF3mg
         Wf9vALbei2EAEFggpbWaG0GCZE5m37AkZ9PaYY87QNI2XZW2+YqqUNLdOD2bLA77BPSZ
         J+VAxtATwlr4H7Gg4R21h2mNaSLyIwuxnMm4XIz6x5Vry2+m448zfcCEfq8tIR4IkMRQ
         Fxtg==
X-Gm-Message-State: APjAAAV4gsAeVw3Qq72Fi41i7a60ZsvSNnpzkhcnFsIqaLX+1K+yB2ds
	uNLJMHubxvENHuqjxCosWtrH1rnyLLDgkqoT6yr7F/1uNJmo3tYJCJhHXinNrQ54JfBKkUJBnh/
	TceuDJLpx6wRct0J7kJUh+WWaNZlR30sTNRReReIyCAZbHk+hGZjLdr9OWyXoEgJc7w==
X-Received: by 2002:aca:aa91:: with SMTP id t139mr169132oie.174.1552933828781;
        Mon, 18 Mar 2019 11:30:28 -0700 (PDT)
X-Received: by 2002:aca:aa91:: with SMTP id t139mr169081oie.174.1552933827931;
        Mon, 18 Mar 2019 11:30:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552933827; cv=none;
        d=google.com; s=arc-20160816;
        b=nujh9yrhwG4aALY9C2bYVZPvto5p4sIRRxtQPXoDj13eBVjW5Irn/BYjdSxGrfqN4p
         q7JsFbBsz7+dGPO1watwOrRmKPuleEYVPZJS1dlZMGfv/qweQ3jGyyOnVZk5iau2C0dI
         YLY59Zc7K7Kls4tmBFGofd8AwSLM0GfrIJngTjXAXUOCdv9czZXK3YmY+fL4RXb5ojf8
         6OZX6jio6y2B/cfTu4eLb5OWKTkqAZkT9m3xkmHcTSDidVn87YY7+a5YBzeMx8SSsZdn
         Gm+7+ON6Gi+9zYh0UBoWf+0JUQVY4/WdRjTHnZQMYt2goOq39exHl74yDG1mI5MQCtYX
         Ypmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sbsTYKGPUf22VNUHUiDumPSMR3YTxTtHfk3y04Q51PI=;
        b=bvGv98X9SaafEXrI/suOquw3drqMulis4OJgWMBU/TkuNDQ94Q0EltkN15Xh9ub9Ca
         4s6rOrL3eFyPxRvJVwe6EWrAD49Zb3OKrqJXYUW4Bn//astbPZV1vQXo88FSCK2K92uV
         BqT+AdEMl+D1XPh/k+7hjixgLCw0MCUrIv3qdPRQrHh55zKG/z1qxIcqhfuw2e/dY7z7
         ujWD7I8skZEpVGNCFXhiNmBrnD+wuDebK9x5SYqqwq7TwAriLxfMQgykcagH94jpM8YV
         8dBnAxZ09s2oPqaNqcx/1kfqWiLaVrncDwhT7TV8qHgtoF7s2Ikd2v298thnf7ZYWt51
         VlxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Ti6WT1kE;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e66sor5688045oif.72.2019.03.18.11.30.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 11:30:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Ti6WT1kE;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sbsTYKGPUf22VNUHUiDumPSMR3YTxTtHfk3y04Q51PI=;
        b=Ti6WT1kEvz5706AzrASGb3DEtp+m8ZO+QEXN5wFB+65Dn64vkucYPUtl275qzWQcDL
         OkR0bul4zxaYW6XYbh4PIZpjS8+i0ejH1t92P0sHeChDtCDzOuJwwPbk3tbyqGkr1I1s
         /CRlBL/qG+BRneir31rdy3ywTvLqDjVal2nUrrGHjc5tnTc+oLaAJ6w17FESSUFhpTTz
         H6oRDlE3nXOpY32QB6p7bgx5T6ZDi3cQ8pYGtpdtYPnvfTmVg+492QO6Dtkv7FhmtV2l
         RHN/0nkQsymYJPOLXNo9xYLbxTdMNX/84V7RB/qzEBmNsVk3fEoiZOuBtFYjxosXSVAa
         No3Q==
X-Google-Smtp-Source: APXvYqy38RzGaS6GmKEWk8AVCslWmyO1VRMUjt3IiqPFlac6gvhzxAIrS42qy+DE9houQ7j4yhnpSI2lrBv5oKHke9g=
X-Received: by 2002:aca:f581:: with SMTP id t123mr198768oih.0.1552933827507;
 Mon, 18 Mar 2019 11:30:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org> <20190318170404.GA6786@redhat.com>
In-Reply-To: <20190318170404.GA6786@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Mar 2019 11:30:15 -0700
Message-ID: <CAPcyv4geu34vgZszALiDxJWR8itK+A3qSmpR+_jOq29whGngNg@mail.gmail.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, 
	Jason Gunthorpe <jgg@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 10:04 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Wed, Mar 13, 2019 at 09:10:04AM -0700, Andrew Morton wrote:
> > On Tue, 12 Mar 2019 21:27:06 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > > Andrew you will not be pushing this patchset in 5.1 ?
> >
> > I'd like to.  It sounds like we're converging on a plan.
> >
> > It would be good to hear more from the driver developers who will be
> > consuming these new features - links to patchsets, review feedback,
> > etc.  Which individuals should we be asking?  Felix, Christian and
> > Jason, perhaps?
> >
>
> So i am guessing you will not send this to Linus ? Should i repost ?
> This patchset has 2 sides, first side is just reworking the HMM API
> to make something better in respect to process lifetime. AMD folks
> did find that helpful [1]. This rework is also necessary to ease up
> the convertion of ODP to HMM [2] and Jason already said that he is
> interested in seing that happening [3]. By missing 5.1 it means now
> that i can not push ODP to HMM in 5.2 and it will be postpone to 5.3
> which is also postoning other work ...
>
> The second side is it adds 2 new helper dma map and dma unmap both
> are gonna be use by ODP and latter by nouveau (after some other
> nouveau changes are done). This new functions just do dma_map ie:
>     hmm_dma_map() {
>         existing_hmm_api()
>         for_each_page() {
>             dma_map_page()
>         }
>     }
>
> Do you want to see anymore justification than that ?

Yes, why does hmm needs its own dma mapping apis? It seems to
perpetuate the perception that hmm is something bolted onto the side
of the core-mm rather than a native capability.

