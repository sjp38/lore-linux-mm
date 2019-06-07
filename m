Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C147C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:11:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC8AC208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:11:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="JamJvjNS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC8AC208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 636CE6B026C; Fri,  7 Jun 2019 16:11:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E7F46B026E; Fri,  7 Jun 2019 16:11:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FE436B026F; Fri,  7 Jun 2019 16:11:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE33F6B026C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:11:11 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id v2so359012lja.6
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:11:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+IlYOcz6MNUONhjjBYHuT8/QTI8M6rG//OnFFoEPmts=;
        b=dn2dqsxaOGfh7goGeM3bAvmJBhm0HGr2gz+hvruJYULpYtz1BevfkNJRGxEC/tbL1O
         ACtUiYXHcbzwUxeAUikxfkydgAIq0fDlSmHmyj1yuz/+kVYInjegyOJq8UaJDf+ghng5
         bJ1z69Ii8PnoRLQT2T8cZjJP0ynziYigJVlW4rp5NvSWRS6eC10IVJAPIAXL3aKrfoP1
         i6sWZJYkW/Lme3SSR1jZ3n436J6i74qAp5vwoGhAykB//E2t6mgMI2PDvKU7WAK4bZy1
         A1Fc+OXsCfK/nKqJ1xMbus9G+PWrva2dMQ+cYrcMxx00rEBsPOLreg2mNH05Vo0ozaH8
         VJDQ==
X-Gm-Message-State: APjAAAVJMTamDxtsiSSp9JKiQ2WjqchJ2EfmSLAVOcOdBrHQu7q18OS3
	wngddz3+QXa0O+Wb1aJdeh9vF7NQS5PyV4/q2CX2eA9vpWQsQpxrKRC14FFd9i4oYuOs4Ltohbd
	RgXL4UbdYOBuwBVtN6G3NQlVr2fzgkYs5xcJwUJ4GWUnzX7bX0HHjA+5AvyzPZyuq4g==
X-Received: by 2002:a2e:2f03:: with SMTP id v3mr29412824ljv.6.1559938271285;
        Fri, 07 Jun 2019 13:11:11 -0700 (PDT)
X-Received: by 2002:a2e:2f03:: with SMTP id v3mr29412786ljv.6.1559938270398;
        Fri, 07 Jun 2019 13:11:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559938270; cv=none;
        d=google.com; s=arc-20160816;
        b=DUA6DkzLhMbVsJ5nzbxbeetJimgB8zGXOafWnI+nPrqcbfgv7A2mc8ZjDQieEtK6XH
         +FBe3ZXsXig3M7m2LNazIdClFVwZpnGjNi3KLNqrqZvvixEdbnGVqO4VG5p+z0ZDKgnP
         eWIraotbGd+96ti5Wxoy0tDDMd3b1HqSuGD464zvsTT69fV02bg43vyO9ErLW8Dugzxy
         4LaCCcw8y20iokqnjcgKHJkG56L3o0Eu6tvcPwZ753LJ6rAsQrzqau8DUZ7PmOo9wK/r
         13VJ3ND/kkx6FSkv09mgRtBIwk4S0FXJPYx61NyildXmbSMvd5lgs+F1IYTlLCZ67mDO
         j3Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+IlYOcz6MNUONhjjBYHuT8/QTI8M6rG//OnFFoEPmts=;
        b=JVZO4SSISAawIad5nfSG7WTyzJK6AITLiYWPDu8nmFW1WidlnLj98ysooF21ndYjXi
         iG7Wcre41QrdT88lXZyNTNJvy6gItu+/sNRWq76QJYFbD1dMrJDYeR0Jjq6JBnnz3rTP
         jYhrJoEiLqJQbntjhOTGv73+tzp2+A2y6JPVx/kTXEDbcVepXujwkHYaqk6lVaGNPdlp
         hN/vPgX6YYrDzQB5FYiL5bC763Tr+Lam8mKLKbXSJrIsrgZw3bqqnVCMH44ied+2LdxJ
         NVYrglruGqcfR0kO4dxzKa4Q0CX2io6NnRVklJhGzT4qjfSIXPcx78LJtnGIk1o1D70x
         fJ6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=JamJvjNS;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v67sor1934965lje.13.2019.06.07.13.11.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 13:11:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=JamJvjNS;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+IlYOcz6MNUONhjjBYHuT8/QTI8M6rG//OnFFoEPmts=;
        b=JamJvjNSga7wum4UHIzRpQ2ggGqR3TS0Ky3ghoX7KcWNz8Sk+A3tuB7WPgceeqShLW
         nkFVY32F//ZpHLDi01RoWYF0DRnMpUJfvGw13D4xRwu8fxepDRERdpAgOw7kRX4gPwDp
         1UYD90Jfac/Amyi8nekd0EYx6+jSjy9ePtfCY=
X-Google-Smtp-Source: APXvYqxQpyQ4ZHsziCB4pvVPM7siIcoZGA60G3utXQ4OrKs/d6gV7/tlJ4o5DAmO/GuQOfVhtnAskA==
X-Received: by 2002:a2e:9788:: with SMTP id y8mr5164446lji.41.1559938269066;
        Fri, 07 Jun 2019 13:11:09 -0700 (PDT)
Received: from mail-lj1-f178.google.com (mail-lj1-f178.google.com. [209.85.208.178])
        by smtp.gmail.com with ESMTPSA id b62sm522635ljb.71.2019.06.07.13.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:11:07 -0700 (PDT)
Received: by mail-lj1-f178.google.com with SMTP id j24so2814555ljg.1
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:11:07 -0700 (PDT)
X-Received: by 2002:a2e:4246:: with SMTP id p67mr29114030lja.44.1559938267141;
 Fri, 07 Jun 2019 13:11:07 -0700 (PDT)
MIME-Version: 1.0
References: <c8311f9b759e254308a8e57d9f6eb17728a686a7.1559649879.git.andreyknvl@google.com>
In-Reply-To: <c8311f9b759e254308a8e57d9f6eb17728a686a7.1559649879.git.andreyknvl@google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 7 Jun 2019 13:10:51 -0700
X-Gmail-Original-Message-ID: <CAHk-=wjKy5503vYoj3ZizGz69iBos69wdrEujojuri67vV=BVQ@mail.gmail.com>
Message-ID: <CAHk-=wjKy5503vYoj3ZizGz69iBos69wdrEujojuri67vV=BVQ@mail.gmail.com>
Subject: Re: [PATCH v2] uaccess: add noop untagged_addr definition
To: Andrey Konovalov <andreyknvl@google.com>, Christoph Hellwig <hch@lst.de>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, sparclinux@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
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

On Tue, Jun 4, 2019 at 5:04 AM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> Architectures that support memory tagging have a need to perform untagging
> (stripping the tag) in various parts of the kernel. This patch adds an
> untagged_addr() macro, which is defined as noop for architectures that do
> not support memory tagging.

Ok, applied directly to my tree so that people can use this
independently starting with rc4 (which I might release tomorrow rather
than Sunday because I have some travel).

                  Linus

