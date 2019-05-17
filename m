Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 913FDC04E84
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:37:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 520352082E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:37:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="VsbWyvJh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 520352082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7E1C6B0006; Fri, 17 May 2019 12:37:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2E376B0008; Fri, 17 May 2019 12:37:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1F2D6B000A; Fri, 17 May 2019 12:37:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3C46B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 12:37:46 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f8so4754118pgp.9
        for <linux-mm@kvack.org>; Fri, 17 May 2019 09:37:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=VgMR8fw/3btcfeCqUg+SAAzIGGZgPBuWMbQyEv64ZSw=;
        b=eQg5iVWRljpsJkmcGD5SyDjkMcrghDN9q2V72A3ig4fnF2JrYIBJumlYcQaHC25rVn
         ksU+c4DNvhLFpGEo1dkXrCUz8rOxZXLklrnvY3Mi9oh+v9p1Kyh1KTEZGU/tkz3PMlkm
         pRYp6p7/y1nho/akXFZdmOO2+wpF6+rlxuZQS7/Fssk/JEot9z7JDVPuble283NPjmoM
         X2QCBaCv3LW1KJ6iz1dJKuAIIvBupZ7ET5aV6ui4KuKwnVpQ3SrtYRJPax4NmXJTZSF2
         XdrtJLi51ZhYjK4M4+OeHPrz0KC7xQsUQ414fRvsWmcmrv83QnJ4dhMrCEsxq4QNJqFc
         UEfw==
X-Gm-Message-State: APjAAAU+AEmoolBlq+aIBoWtDjhdClEU6YPxreF4lrBA1NcGANz/2gI7
	nUoudITkzy1/uAeCFFU7qN4YU06aVb7n0tt1VAiRcJw0XCtvlMXBV3k+HeR9984PUVVu6j16LuD
	w/46BT6e4cNtGNnA5YPtOApCapqL/yo6KU7y10vim4Pw/BBnQd1kmOmfqvhC5Z+azzg==
X-Received: by 2002:aa7:9ac4:: with SMTP id x4mr62103028pfp.43.1558111066243;
        Fri, 17 May 2019 09:37:46 -0700 (PDT)
X-Received: by 2002:aa7:9ac4:: with SMTP id x4mr62102980pfp.43.1558111065669;
        Fri, 17 May 2019 09:37:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558111065; cv=none;
        d=google.com; s=arc-20160816;
        b=GSns0S8ayBiCR3JcbJa+FipsX4B75ZbMZlbNGtcmcGeoUFVEhzy3J1k/MB/Wf6CS/+
         U3OplPZtUg2hT1FFJrLzcYqD533EW9ACEbIAw1Xu79wP8At28CWZB1YTJVQpAbQAxOW1
         Or+WIso7Ai0wK9Y/vgnYvUKmxXol+VKYHu8V2LThdaZF+KCwc4iCUGLs3Nd0fdUgeqGk
         CvGXYkwHfG7IoHSb8FAewfZXIA+KwoP+Jg3iuFaZCrQufRnGGobY642zsH+L/OVxmLEX
         X2euukuvApmD62ClgZHeb0fxgGtykUokpsqolsG6Bagdfpzrh5IC50SrNwueITWJPgrM
         3cRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=VgMR8fw/3btcfeCqUg+SAAzIGGZgPBuWMbQyEv64ZSw=;
        b=axW12xGCuw1Jh8ArWr+Hn2b5i81w1zHpJPvdUYYP0Mga7K5FDXeS04vpdWwLrEBl/r
         5WBmvud8dA0y3n9sePTzXx86sc/oZsqUMkBict065y610ML2OEKdFg+/1u02PaC7ZbZb
         J4lzDloHEofWAVtu2HBkO67/f7DnBa511ksMFuHvcdwBJ+02fVMhD+77SrJcubae5J0y
         endKuf5pMlsB/gHLTnSgF9oZtEKY+A15/2lfdUMTo2kqgNZ5TpZOCwtADEF3FnB/QlhV
         Q+o4DbFb7/+MlnieOueH03TAlKIaiSu4sn9reQmBPJlGQwIPF2avRyRHvnzImCScDnEz
         OqtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=VsbWyvJh;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v64sor9297183pgd.48.2019.05.17.09.37.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 09:37:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=VsbWyvJh;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=VgMR8fw/3btcfeCqUg+SAAzIGGZgPBuWMbQyEv64ZSw=;
        b=VsbWyvJhK63OLyZtQo8OaklsBhS46OZmNozcVmNGar+obQPJhvlUBVqOtwGNUSk1eg
         XQLDrD2d4ySpIj+jC/9WTu8arAVvxo1JKc+nmnC7ij3hJEvOBgk1CqWeKXnT7VCYKeoC
         VGVRU6vvl7th23Ka2qGEjSEJ0XcL1IbV/xwEs=
X-Google-Smtp-Source: APXvYqwFidnBAPTL+woN/ou51mJsyoX35Z9berovyuDT4vsLcTEwjuG1xg0yIHCeu2pFUSIcHbV0oQ==
X-Received: by 2002:a63:4342:: with SMTP id q63mr57175169pga.435.1558111065442;
        Fri, 17 May 2019 09:37:45 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id s137sm15534495pfc.119.2019.05.17.09.37.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 17 May 2019 09:37:44 -0700 (PDT)
Date: Fri, 17 May 2019 09:37:43 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>, Jann Horn <jannh@google.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 2/4] lib: introduce test_meminit module
Message-ID: <201905170937.7A1E646F61@keescook>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-3-glider@google.com>
 <201905151752.2BD430A@keescook>
 <CAG_fn=VVZ1FBygbAeTbdo2U2d2Zga6Z7wVitkqZB0YffCKYzag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=VVZ1FBygbAeTbdo2U2d2Zga6Z7wVitkqZB0YffCKYzag@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 05:51:17PM +0200, Alexander Potapenko wrote:
> On Thu, May 16, 2019 at 3:02 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > On Tue, May 14, 2019 at 04:35:35PM +0200, Alexander Potapenko wrote:
> > > Add tests for heap and pagealloc initialization.
> > > These can be used to check init_on_alloc and init_on_free implementations
> > > as well as other approaches to initialization.
> >
> > This is nice! Easy way to test the results. It might be helpful to show
> > here what to expect when loading this module:
>
> Do you want me to add the expected output to the patch description?

Yes, I think it's worth having, as a way to show people what to expect
when running the test, without having to actually enable, build, and
run it themselves.

-- 
Kees Cook

