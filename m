Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6548FC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 05:13:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A6B520850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 05:13:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="iVgLfh3u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A6B520850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A97EA8E0004; Fri, 14 Jun 2019 01:13:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A21168E0002; Fri, 14 Jun 2019 01:13:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89B528E0004; Fri, 14 Jun 2019 01:13:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50FED8E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 01:13:58 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y5so924588pfb.20
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 22:13:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=7L7uajw4KCsbL/S4E35UjNUKEFnxH/l2jD/CiFHPlB4=;
        b=LcalUCgM+qozKkCSeFo4+t+6IV7WQ2DJe5Ji0HV9dT3r333JkErrofRpqKzduIRhA6
         TQtK2kfxHSMo5tse9I6NBcpnuBzOb/b3UrS7yEso9KWwz+4o08irLU6kbjsLLTxk9YwD
         rCIYFwBYQLPkvXAEQsdpmy5/Q/8F2XcFjR633sjcjEy5libPY05/RJ6NNVfCQMCLG7UO
         eNos3h0tvbiWJsf7EFs8R1I6GVyZfiHe4TaGZLbumNhDljamprRPuidl5eh1jfTursaX
         27R7/rGGfkntxxIY9vXHLy5glaLq9WpTU6iarHtdpFmuFbbPHuMA27aFsAhKe87a4fN9
         QuQg==
X-Gm-Message-State: APjAAAW2P+CZtWHqg+MUJHWLfouY6qasW+kXI1ZQpnvntKLp4SEvIBdL
	eU/zNKreu93BWolumZ0C8/0nVLlShfd1ajYtffVTV2shvc20TK5U0Cka9kN5yt0as98cggWob99
	vqbDN4c0dblIfP6YWTNLEboZPOjpuD1Brai+srG2Xa5/9BSyUeGeZIPC6Jj0W26Jp5A==
X-Received: by 2002:a62:b40a:: with SMTP id h10mr97957588pfn.216.1560489237889;
        Thu, 13 Jun 2019 22:13:57 -0700 (PDT)
X-Received: by 2002:a62:b40a:: with SMTP id h10mr97957551pfn.216.1560489237213;
        Thu, 13 Jun 2019 22:13:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560489237; cv=none;
        d=google.com; s=arc-20160816;
        b=DdiOsUtvmJJIxQNRmtK9DHG/F58GZ3qG0dmFTDsQoumASc7AFIpMoJEsAWk83kHwWc
         SQs74X/MmAdrlmug4spLVcgVifN1Et9z2rPvfV5IUaTRPwv74Rg5SgqG6lB8bQhVPL35
         IWgrkSE/NQCOHRH0JoIDooT6CDTxNO7bTnh7rTYQb2AgVergNVEzoInTd+SirRbJLLTX
         fCL8AIXC0099cv+grLD7pjSVRA/HK89aHhnY34Ln+TxaqMqJw6yu3bxTv1iz/SNG1GrF
         atgKwmB3is6fcPZ2j8tmbb3fhhfQNmOusTNYc4UL94GLIFvGmTl3ZQ4Q2PH5sT6S5j2X
         cQWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=7L7uajw4KCsbL/S4E35UjNUKEFnxH/l2jD/CiFHPlB4=;
        b=jRf3zE9IhRjvzvcTcD/xmVKP9hJqYIVsKnClna5gz4SOH9V/8cumRBuKjJMgJrOOkp
         ohvmFz4m/B1Pzk8SXrwnrI7sjjcPZEyI3+uUaYe1T43CSL2TTUrXK+d0j87JP522pCKJ
         VbeqBN+sv2aN/7IlDKgXflhrN53djEtKqC2TgGldf8XTdHTZOfYokH7BvKto2vf0BKS1
         G25kikhd6ZR/X5dwoSX7tKAWOMX9LG0/rbSwj1F2ZBhWF907Lm2UNsZERaD3qwtilfU1
         32IbNKCu8Fu5pC30S3BIEYLz5ed/b/4MtIy3FWhzApLHsQZSZh8gi9UaIQf1ftTfL2dQ
         R7tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=iVgLfh3u;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3sor1951511pgv.29.2019.06.13.22.13.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 22:13:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=iVgLfh3u;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=7L7uajw4KCsbL/S4E35UjNUKEFnxH/l2jD/CiFHPlB4=;
        b=iVgLfh3u2rK3LSidDHhJBtdtNtpSlz4dIEb1BDsj4Re2fjkTLPAq5VHIrDbtF7rfc6
         5a9vwqPeA/oCez/a3NCM+60PRvHQV0ltptm4u18TbaZDEEEiYlVGWcXj0ugZtZMkqFnM
         ltnmFCb7F68lK6w+sv8Frqic/ZXdf9np/Ivm0=
X-Google-Smtp-Source: APXvYqzTfasIXQ0R9bH+BHnjS/rxhZOCyiy3olY/JYV+P2HTQ7p4rEZDPtcIb7Np5EQm4YDFboUW8Q==
X-Received: by 2002:a63:6948:: with SMTP id e69mr23166361pgc.441.1560489236782;
        Thu, 13 Jun 2019 22:13:56 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id f13sm1417022pje.11.2019.06.13.22.13.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 22:13:55 -0700 (PDT)
Date: Thu, 13 Jun 2019 22:13:54 -0700
From: Kees Cook <keescook@chromium.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dave Martin <Dave.Martin@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Mark Rutland <mark.rutland@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <201906132209.FC65A3C771@keescook>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <20190613110235.GW28398@e103592.cambridge.arm.com>
 <20190613152632.GT28951@C02TF0J2HF1T.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613152632.GT28951@C02TF0J2HF1T.local>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 04:26:32PM +0100, Catalin Marinas wrote:
> On Thu, Jun 13, 2019 at 12:02:35PM +0100, Dave P Martin wrote:
> > On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> > > +static int zero;
> > > +static int one = 1;
> > 
> > !!!
> > 
> > And these can't even be const without a cast.  Yuk.
> > 
> > (Not your fault though, but it would be nice to have a proc_dobool() to
> > avoid this.)
> 
> I had the same reaction. Maybe for another patch sanitising this pattern
> across the kernel.

That's actually already happening (via -mm tree last I looked). tl;dr:
it ends up using a cast hidden in a macro. It's in linux-next already
along with a checkpatch.pl addition to yell about doing what's being
done here. ;)

https://lore.kernel.org/lkml/20190430180111.10688-1-mcroce@redhat.com/#r

-- 
Kees Cook

