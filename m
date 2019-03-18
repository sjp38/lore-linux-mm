Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9F8AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 19:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B8DA20828
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 19:37:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="JpXTIgcA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B8DA20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED07E6B0007; Mon, 18 Mar 2019 15:37:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8CF06B0008; Mon, 18 Mar 2019 15:37:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D489D6B000A; Mon, 18 Mar 2019 15:37:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 95E116B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 15:37:08 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id w20so8715089otk.16
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:37:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=R0CxR5bVCegbln6z7376+bO3M7CvxMN5kr55cG4eMTQ=;
        b=UEz3Dxu/87jNX2P0ixuqKx0C2Yx+HffPEhCBprp5zT0kgxZChEQYLVYFtmk1wLfSLX
         fnxGBUkNmCCTRfQeRGb8DWnLyDzkRQT73s8IzWSb3BpjcZBMv//lTWotjVZItFCcHY5J
         G6vA3dIben5vcgbmYfWHTnx+m6TARxEEKH4bCLMKW9RNQeOihJKciZyaHv4NDykMmoQv
         W4iPNcmkfJMJtt9X0x4i/LT0Otue5a/p2TWUtrvFSR8URYERy5MsIvFmnCwaWlGfowaP
         oKLFU5x4VWnr3M81Cr1dZfJEYBogMF04cCj09yplQst1/tJFlspE3GZL8hQSR24Y/Flq
         4ZZg==
X-Gm-Message-State: APjAAAVr/cvcVc72dfwpuxGX+1hlT5t7y8Zf9M+M+vXsbFpooFldfAEB
	JxRy62oORMwYuuME9uprbH+gz3n2TQPyVLw0uYw/p8mp6wfBgk3jYFTtoUwtkdJTDodIhnaWirp
	jAYYxY/e8tSBhD1gn+FWf4j1Qz387brel9wzo9MLseS3Mf5ZP2+zGb+7KYuLg/kR4iQ==
X-Received: by 2002:aca:355:: with SMTP id 82mr382582oid.30.1552937828229;
        Mon, 18 Mar 2019 12:37:08 -0700 (PDT)
X-Received: by 2002:aca:355:: with SMTP id 82mr382545oid.30.1552937827484;
        Mon, 18 Mar 2019 12:37:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552937827; cv=none;
        d=google.com; s=arc-20160816;
        b=ofGLCshnbNrDX7YXEdu7bJqPovuDppgdURMnQdPlJo2fMjRmX3GLhoWa6PC4fj7EWB
         69oc40XmQnAOD4MdD0i9RsSk15GHv5VpSn+bM0XXGdRByNm4ee+MbBrKQgHSxCVlT69l
         4Xsrtiazj7AM5l+y4LSpqSlkYy2TVCq8JLPx/EeM1wxI/03cSNs969U7FKQq9WVATeXe
         2OfZBXNRIUqgeVMZHcYEn/3XvnEczNsBp0rlo9qLpvCW6w33+DMOCSBl+w5HdrOU6A0s
         F68frXYiapfm5cwkU7nA4Fq6sJjDLzFJNAq5UgZM/Xc1yHHF3L345O4dUuy6h7rExe6K
         tt9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=R0CxR5bVCegbln6z7376+bO3M7CvxMN5kr55cG4eMTQ=;
        b=G07SyP0DR/YgcADzPjXx1HKbqMlC5wwMFdNGNZO5SKUjEo0GnuX9vphY7VeqV9PayX
         fYBGHELFLNvRLwLAEyhLGrM5cumEBiBeQTSwVDtwk1AcVydu0hMP3DQZnOA32Yf3zd6N
         tPR6rYUGiN8+D32ihbPGiALeCZuamTxHCy/A9rIO+Hl2heQoAlvZ+sFhqBicwsKSrw/g
         QZQpvwo+uxbqI9UlkdA9bXofvUCqWhMXMFUMzVVUNYZ6WVq/sGc4ySEVTYvw3RI25H+n
         YW4+t+YU2qPYJ4gfzcgvfEczbLsR/irm0O2tnsd9TeaT4iyPjDv7kDFb9w3PYIv787t/
         Gx3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JpXTIgcA;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s19sor5640701ois.68.2019.03.18.12.37.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 12:37:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JpXTIgcA;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=R0CxR5bVCegbln6z7376+bO3M7CvxMN5kr55cG4eMTQ=;
        b=JpXTIgcAvV8LCsUvBBsftaCQmXvSVhY6EuRPkcwx70+Cx9YgQLS6i5F3fQHPMVpbEG
         w3iuA2JhsE4Vp7tLmG7w7L4DyeI6JbLFS6IBzLCTiDK43Yyas2wF+kQMdA6PRwybJKG6
         9SWodxq/sXld8k9Lf691R0peGnls10J1R6gf9k222HW3FLAJ6g0T73CUtFaXwBFR+vCb
         nYI/svNps8B4NQj1ze53YErOFVpFmkcp4xQS/CE3iWz9iOGgRzkS1C7qmDs4G+hco/sb
         7X0GS3gazoLLB4fu9Ui8xvaF6Ydhbvfd9uzDVq2VLVFTBPA7H5t1mrCFZohtFvw+3B51
         SZPA==
X-Google-Smtp-Source: APXvYqzqlvRNoPBAp8dvQXRPlsaqLot8U8X7UtNFbKuyWp/Q0PRYCRj8UZK17phWdiYuXR5fTuDf1cWkaimd+/HIiuk=
X-Received: by 2002:aca:aa57:: with SMTP id t84mr345663oie.149.1552937827180;
 Mon, 18 Mar 2019 12:37:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com> <CAPcyv4geu34vgZszALiDxJWR8itK+A3qSmpR+_jOq29whGngNg@mail.gmail.com>
 <20190318185437.GB6786@redhat.com> <CAPcyv4gLyKkboZ-ucHubiHgdpF4i9w+XKhPujjJ=dwU9Vox=Bg@mail.gmail.com>
 <20190318192858.GC6786@redhat.com>
In-Reply-To: <20190318192858.GC6786@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Mar 2019 12:36:56 -0700
Message-ID: <CAPcyv4gotYtvo7hupYCxYsYCmNHaf8yoYgfi53N3AhuvMmT1zA@mail.gmail.com>
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

On Mon, Mar 18, 2019 at 12:29 PM Jerome Glisse <jglisse@redhat.com> wrote:
[..]
> > I went looking for the hmm_dma_map() patches on the list but could not
> > find them, so I was reacting to the "This new functions just do
> > dma_map", and wondered if that was the full extent of the
> > justification.
>
> They are here [1] patch 7 in this patch serie

Ah, I was missing the _range in my search. I'll take my comments over
to that patch. Thanks.

> [1] https://lkml.org/lkml/2019/1/29/1016

