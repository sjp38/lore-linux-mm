Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21651C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:45:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8A3D2082C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:45:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8A3D2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62A086B0003; Wed, 12 Jun 2019 06:45:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B3A66B0005; Wed, 12 Jun 2019 06:45:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4545D6B0006; Wed, 12 Jun 2019 06:45:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7C826B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 06:45:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so15924933edx.12
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:45:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=N1Uh7pDcKlpiURRyEJ4tMCtKh47rfvj2yCRBpRcsM/Y=;
        b=jvC61ErCvvjaiYSMT18RNHPdu64pPWAEkX4dXpblYZxJtSbMokI0l3o7K+5ztVlex/
         IYWmp3Z592KEdxGXPRb00LoxrEpsy1Yw9OSGxksBe0X/WL7ioJ0s2RdiOeuxk8zpNBMu
         Yfy9nJWcm5iTx2HjdY/S2tfCGpmq5CKSzVwRD9eTGjrN1cnQs9wVahivlZfOvGI7ZFRq
         E9zk2h7AEYEsloSrMBRWjZ9XLotEJCqw4MQrM5wc6vQ4Zd0vzL/3FAXS15hmGqfpXxJJ
         g5Z66j+Hfz6oVHCuJudZj7hnW0SKoUw5rjhytWvZGSk211E7xOebUJq4+XAxrI+GC8JX
         29jg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXiegrUde/5gy4o2n1UfUBvRECYJSN66tYxUUZ6cwCjRn099/nL
	YgwDRNCAeUsjmv9eplfGie1zWzWWGBYVUnbhf5K1I1ODvLzB2j9oORmpKXbvxkBAJbSUDd6nZsm
	TR3+EuTHIRTYFi3fZCtd0YLyb6Bfi5dMD/TaQDxRiLlJeqUf7KoVqvuhR3IZVCHWFaA==
X-Received: by 2002:a50:b561:: with SMTP id z30mr32069487edd.87.1560336347520;
        Wed, 12 Jun 2019 03:45:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyy8+PrSTvcWRP8Bh7Op3N1x/wInI5/kmNGfApuVuP1j9fXkCnJRHbsOc+HooWqZ+tf5MR0
X-Received: by 2002:a50:b561:: with SMTP id z30mr32069431edd.87.1560336346856;
        Wed, 12 Jun 2019 03:45:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560336346; cv=none;
        d=google.com; s=arc-20160816;
        b=UgJgTk1XimOlytTTwKyEeCvZqFrHiQttNsODUAuYlxqo3NXmBCW9PZesrlqwMuu+HW
         MJYwnLSU4bOJfkI6esOFaIMaf24l1j3xQeWftThVMdV5NBDb0jkm2cHqyqKUqJfmeyEY
         SrdyTNW587hxJV9cwBQJ0g8hEW1KsazfiKuyC52CYxr1UPAvqW2H8kTHaTUIz1aw4XtT
         JlnEEzZBms98m86ZAdAQ8xX8UdGYiXWttj0TSg6DAxi6W/nEVceU8tfT3sN4v9Y1bcHM
         Ei9IsXl5niZFZmDmyqU0SbAy3aR9az0ZoOoNcWVy7qjOzWhGE9sdlqrORGXg1KwerITY
         E+kA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=N1Uh7pDcKlpiURRyEJ4tMCtKh47rfvj2yCRBpRcsM/Y=;
        b=fmg5UefH/P86lXO+d9zKsFZrfqlZhJeWpviuB0VtDtS+l54vSrH5x34LbAojCUIFsq
         34K8Y6oXPRrF6tR0pGYkQdmhPRbkWbAAYAS+t/zSkY3YfpiY5XVSmw3DXS/j5UpkX1uF
         7tIMZ5vXTlJjb4xw0XJ52DrXoTyc0x4Dxi7MjrugKv3HC0101OSY1QPENiJQkwPCBt41
         k3BTI3to4K74M/K3pLGoKtUG/TDS0maeD9fcepD5KdId97i1ePADhk/q7CESftej4E0j
         peumetTvlEACTrpAHt0ngawaE5rpv2bcrX4DN82Yg3bqex7zaDBrg77yVvsyTQCvc8lf
         gstw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v1si1046179ejk.50.2019.06.12.03.45.46
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 03:45:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8B34A28;
	Wed, 12 Jun 2019 03:45:45 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C9D343F246;
	Wed, 12 Jun 2019 03:47:05 -0700 (PDT)
Date: Wed, 12 Jun 2019 11:45:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 09/16] fs, arm64: untag user pointers in
 fs/userfaultfd.c
Message-ID: <20190612104517.GB28951@C02TF0J2HF1T.local>
References: <cover.1559580831.git.andreyknvl@google.com>
 <7d6fef00d7daf647b5069101da8cf5a202da75b0.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7d6fef00d7daf647b5069101da8cf5a202da75b0.1559580831.git.andreyknvl@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:11PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> userfaultfd code use provided user pointers for vma lookups, which can
> only by done with untagged pointers.
> 
> Untag user pointers in validate_range().
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

