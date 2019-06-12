Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C386C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:14:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37AA8208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:14:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QkhZMvI8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37AA8208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE0296B0007; Wed, 12 Jun 2019 07:14:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B90D26B0008; Wed, 12 Jun 2019 07:14:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA7AF6B000A; Wed, 12 Jun 2019 07:14:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 709CE6B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:14:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y5so11773887pfb.20
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:14:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ICAcqmNM80YqXGU9u0yKcUq/onm/SsQo2SDs/l3f+hY=;
        b=KjnAOQMyMJEw5unIyyzO47yYCNtE4Y7Mhoj18fFa+ZfpLUUwLdQDWDWwgey1WCxfgj
         xkOk856MaECs8gQARLr+qGprqNsSpJPITduZOvrrv8wugPflYj47/lu/z4f3jCO6eyDh
         LjYVPnTOJPKkgBuoUeFVnqJlh2gJhk+8l7nQgHHXk6VtEYS6x8JBGOz9YIlEeXOJSKD1
         DGFKsuR0ANl+1ARxjCs22B8W4UUSdv32qLQLNJMm1N4QHZ3IN0rpOpqC54QS2U5JtapN
         fDcLLrIbJqiNDa0p0g0WwApAphjWH7Es2QOQVUq3jKRJX+b0vDKY5Z6BsNgd4ZIEp/Yp
         EvnQ==
X-Gm-Message-State: APjAAAUQZ4CD4HdtjPqJN7bbVmt358cunJFIMZSFwqDKQArv0pR+tMoO
	TFe4/R3/Q4uWKP7CdjNn03sVecBTCGMxUYNfWkEC4SwgmV3jizALK2DgvJCvumt2bAVsfXWz+ql
	MLzB5X19mwQ5BjcOKfMkqIvyzHRYwSgNBklPZ5P+arfatE9sgn6k9qVd0nSWuLC/pLw==
X-Received: by 2002:a17:90a:9dc5:: with SMTP id x5mr30876634pjv.110.1560338083105;
        Wed, 12 Jun 2019 04:14:43 -0700 (PDT)
X-Received: by 2002:a17:90a:9dc5:: with SMTP id x5mr30876581pjv.110.1560338082363;
        Wed, 12 Jun 2019 04:14:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560338082; cv=none;
        d=google.com; s=arc-20160816;
        b=ySJYZtQg9CfPG8MvgcBFGh3eCisRIpp8uN5hxk2VkWPDtzfCy76Qy3eZY5vMfXweBM
         PTHhQowI19hQpHco+L8TNIIL3SamxXPpRkIZlqcjORq5c4rgl2prfw7jhWU/1YGaYrB2
         4F/nS2vzq536jYRGVIKOBtBt91Ui+0M3g853td0nCDGSyu0lR8Ql5nvHVpcuiPtHfrDo
         78av5P0QlG4f0F4Uiy8BFT0mRhAonpN00IbBK9ZBn4bDU3rS8L0R7isxArbhu21riXYt
         krNZj9cX/bp6xIw9kn5RgiMJKkv0a4ciqRKTb+4Pxm2vVHOOxp+kvfoNONpTm3+fK4sK
         N9Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ICAcqmNM80YqXGU9u0yKcUq/onm/SsQo2SDs/l3f+hY=;
        b=TiEidZL5mW+LqSFaYbCuMh5ymlYYU2VywNdtSh9ZjHSOHlTK0+79AxzI1REC6PNieP
         MbRwjZNmcyK04kvjt4ph2GT3sQkAT6Y3viiZHhyYLlpwk9wBDWu42GDn75LL/mGT28q8
         vQ5fdp7fHSwHq0d6iNF5CPhttgfvRTATMtpVcalWKc0aUZRCArmpoVEr3akDbEvQtirQ
         C4/79UajoeSztBjqSLu0DYwRoFMebR9Hww4ihZsGcsNT4V+vyfZCWPFxXIa7N7G0S/sj
         A1H96bpJrEF/dQaLLDDjNlHO+QZVF71yfrzcltUAPKPW3btr5c5xzP7uFUVJUI6FA681
         0gtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QkhZMvI8;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c15sor9875342pls.61.2019.06.12.04.14.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:14:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QkhZMvI8;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ICAcqmNM80YqXGU9u0yKcUq/onm/SsQo2SDs/l3f+hY=;
        b=QkhZMvI8xgho9eMFZ7w6J/3duhWcdGLEkVVUAU2qSaxNfXU+GXLc+PdiUdCpUn61iY
         0xCUxQ9wiA1Jj7ZnvEwSzmljdVe71a10tK0t/VIk6vJ6KuoIESh9plrNP00oJ9EUV9CE
         7ZXKJL/NmCDrLh5D1fRV3U/5XcSqnaFIYrJ7IhnmnWDC1y2ZQhZMwMFDrVZ4wkPjj2PR
         KjnNxVxOeNHsZ1yb6hgnM2H6TbZTzWPz9Cffq6e0f9rEpBuiI2bynmdfsgpQFhae4y5r
         LLRsk0MnIrY8OwbkGOOGkhYBEu+P7mFEBBswTcH9Mhn9r0qq9AEF/SsRyiNTxER5NtY3
         eTUQ==
X-Google-Smtp-Source: APXvYqygEZ27HGfNqszCpdSgojAf7S6ru14/DaT8Or0Syv3FL9sWDfZ+9LXBU0/5Hxbzx8tkSmaHaZjTcL+f/jghf7s=
X-Received: by 2002:a17:902:8609:: with SMTP id f9mr75570344plo.252.1560338081704;
 Wed, 12 Jun 2019 04:14:41 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <9e1b5998a28f82b16076fc85ab4f88af5381cf74.1559580831.git.andreyknvl@google.com>
 <20190611150122.GB63588@arrakis.emea.arm.com> <CAAeHK+wZrVXxAnDXBjoUy8JK9iG553G2Bp8uPWQ0u1u5gts0vQ@mail.gmail.com>
 <20190611175037.pflr6q6ob67zjj25@mbp>
In-Reply-To: <20190611175037.pflr6q6ob67zjj25@mbp>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 12 Jun 2019 13:14:30 +0200
Message-ID: <CAAeHK+x4sHKfQx31uQ9zSO48oRs3XLATfymY=vgEHQ1FLNmeig@mail.gmail.com>
Subject: Re: [PATCH v16 16/16] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 7:50 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Tue, Jun 11, 2019 at 07:18:04PM +0200, Andrey Konovalov wrote:
> > On Tue, Jun 11, 2019 at 5:01 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > static void *tag_ptr(void *ptr)
> > > {
> > >         static int tagged_addr_err = 1;
> > >         unsigned long tag = 0;
> > >
> > >         if (tagged_addr_err == 1)
> > >                 tagged_addr_err = prctl(PR_SET_TAGGED_ADDR_CTRL,
> > >                                         PR_TAGGED_ADDR_ENABLE, 0, 0, 0);
> >
> > I think this requires atomics. malloc() can be called from multiple threads.
>
> It's slightly racy but I assume in a real libc it can be initialised
> earlier than the hook calls while still in single-threaded mode (I had
> a quick attempt with __attribute__((constructor)) but didn't get far).
>
> Even with the race, under normal circumstances calling the prctl() twice
> is not a problem. I think the risk here is that someone disables the ABI
> via sysctl and the ABI is enabled for some of the threads only.

OK, I'll keep the code racy, but add a comment pointing it out. Thanks!

>
> --
> Catalin

