Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E595DC3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:45:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DBC822CE3
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GJoHV9QE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DBC822CE3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 371136B026A; Mon, 19 Aug 2019 11:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 321776B026B; Mon, 19 Aug 2019 11:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 237176B026C; Mon, 19 Aug 2019 11:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id 0376D6B026A
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:45:10 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A6A33180AD801
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:45:10 +0000 (UTC)
X-FDA: 75839601180.14.net21_4a2f7b294b50b
X-HE-Tag: net21_4a2f7b294b50b
X-Filterd-Recvd-Size: 5453
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:45:09 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id w10so1438173pgj.7
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 08:45:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zMGg7ZRNK7NfpqI/Qet9Dxr9rbclh2xtbR4hUTFM6IY=;
        b=GJoHV9QE4xGJAUCqD7zOGEihP3UiAZjpj3bmVElnV3mGgDu9+IBupxqZo5crTOTBSn
         9E4KUL6HMvh/OBYUcO8Tpulqz8WiyGQenGKjsASlkTFv2dXi8Y/niM3/Z+P7vnlKNIaZ
         MtFd0UdR9JYH1Lcgtiq3NMGR7NeTcmBx3BytYCkuY0+Mh6In/PjXGCT7JB+YD1Ki2rnw
         M/YU/3ABnIwEbCJlH3DAt0qAYIkuPOryLlR92BarOXnc/HJERVegrVcC8hFgAU/vJ7Go
         FvSFH9zA3QmxP0Me+8WMdbNNwakaShO+N+03UzcmCf/+VKatv8Kx3ZtIc9UnmtYKv3wf
         5kAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=zMGg7ZRNK7NfpqI/Qet9Dxr9rbclh2xtbR4hUTFM6IY=;
        b=Bq3kGhsB4XNXvG5f9Cr6Spsy/ZgCBaW6Z4scKGPavNipU9woyY7xupc2W3jlRGTdV1
         gRjBCrhEJgaitVoagF+BPNWmlP/p6mBkY5o7YJP7CMYwZVvFuTyaEiooUtRoZ2KJsdR6
         Sb18uEE9XSYi7uF6xoJULiKszviQmrtjRdOG6To43Xtcm49bvJTnoXTNpF3Ph0l2staF
         Jyoo3PjwgUfBUvtz9syUUqHkARmlT9GZmrZyzrlyera8tIeAbIhmA06kwrZC7jCid2Pr
         lEYzoBBtfO4l1iZ1irJxy60cY3M1e+XHYV+KECorGuXKadsj/JCZeLlsdMJVX6RYinzz
         Fq4Q==
X-Gm-Message-State: APjAAAVcblQIVOkzgNl3aYu6pGi8T35DvFAkC82vzMX/0kF0CJIkwdqG
	eD1/vdh849Fn96YzNeysey9Al23iHDedFw471uyRfw==
X-Google-Smtp-Source: APXvYqyflWC4oeyk4cX94v5k6CQJ/8FEDGgMF+Kmp2ZaCbPDE8MBxb9njXOAWHJ8AnGwbz7Ioq7XIseAIciXEoaHYEw=
X-Received: by 2002:a63:3006:: with SMTP id w6mr20727946pgw.440.1566229508161;
 Mon, 19 Aug 2019 08:45:08 -0700 (PDT)
MIME-Version: 1.0
References: <00eb8ba84205c59cac01b1b47615116a461c302c.1566220355.git.andreyknvl@google.com>
 <20190819150342.sxk3zzxvrxhkpp6j@willie-the-truck> <CAAeHK+xP6HnLJt_RKW67x8nbJLJp5A=av57BfwiFrA88eFn60w@mail.gmail.com>
 <20190819153856.odtneqxfxva2wjgu@willie-the-truck>
In-Reply-To: <20190819153856.odtneqxfxva2wjgu@willie-the-truck>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 19 Aug 2019 17:44:56 +0200
Message-ID: <CAAeHK+zf_VKOttBVfZUdp-ra=uNTx_faCmJkrM81BzgEaOZjSQ@mail.gmail.com>
Subject: Re: [PATCH ARM] selftests, arm64: fix uninitialized symbol in tags_test.c
To: Will Deacon <will@kernel.org>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Kostya Serebryany <kcc@google.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Leon Romanovsky <leon@kernel.org>, Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Dave Martin <Dave.Martin@arm.com>, Evgeniy Stepanov <eugenis@google.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Kees Cook <keescook@chromium.org>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Alex Williamson <alex.williamson@redhat.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Dan Carpenter <dan.carpenter@oracle.com>, 
	Lee Smith <Lee.Smith@arm.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>, 
	Robin Murphy <robin.murphy@arm.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 5:39 PM Will Deacon <will@kernel.org> wrote:
>
> On Mon, Aug 19, 2019 at 05:16:37PM +0200, Andrey Konovalov wrote:
> > On Mon, Aug 19, 2019 at 5:03 PM Will Deacon <will@kernel.org> wrote:
> > >
> > > On Mon, Aug 19, 2019 at 03:14:42PM +0200, Andrey Konovalov wrote:
> > > > Fix tagged_ptr not being initialized when TBI is not enabled.
> > > >
> > > > Dan Carpenter <dan.carpenter@oracle.com>
> > >
> > > Guessing this was Reported-by, or has Dan introduced his own tag now? ;)
> >
> > Oops, yes, Reported-by :)
> >
> > >
> > > Got a link to the report?
> >
> > https://www.spinics.net/lists/linux-kselftest/msg09446.html
>
> Thanks, I'll fix up the commit message and push this out later on. If you
> get a chance, would you be able to look at the pending changes from
> Catalin[1], please?
>
> Will
>
> [1] https://lkml.kernel.org/r/20190815154403.16473-1-catalin.marinas@arm.com

Sure! I didn't realize some actioned is required from me on those.
I'll add my Acked-by's. Thanks!

