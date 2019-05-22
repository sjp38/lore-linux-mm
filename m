Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99931C193F2
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:56:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6946721479
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:56:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6946721479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06D3C6B0003; Wed, 22 May 2019 06:56:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01D856B0006; Wed, 22 May 2019 06:56:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4E3E6B0007; Wed, 22 May 2019 06:56:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 95F0B6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 06:56:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r48so3106808eda.11
        for <linux-mm@kvack.org>; Wed, 22 May 2019 03:56:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+Mm7B1NAcDwkPHWQyE15lGI1eeyxaVtjrsxpzZh2l9U=;
        b=TarzyNKoy/67InyNgWyfIed/laWxxSMwqTlEOPs1CK3QZEgZK8bga6zxi3z1Xd9TL5
         zJ/Pv0k2cFen/QXVS4p/eWr9znimTRFSnrXgKKcfD+uRI5okQVt4RTm85iE5FnOtfAQd
         /j+dfY1mas+ua6tnkDJiV4NbjXCo4wIXgGxDWQOWnqOqoDDBh4f7aIvS1Ypql+Rfu0Mo
         g1pNaKxbL16ZfiDSIm/qGzJbVmYkKV9WCyIsZq93A9GfMfSvaruEsZ1qlsV6Vm8ojFxO
         uLx24Ci3dxmgb2wuOaHST/kJFHvG+airMrbf+Dvfps1IHV6wJWUHcWM9HKD1K8lvvzpg
         +NmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXj3E1ai/QEtVow1TnCGdsfe9GnpnRbY/X13fW1PCGxdBQ516Se
	MDItUi4tzFf9OfW50eQ9cmFyqinxERPCUfwK54nJfuuyiV8bf4IFVzROeJOUBnOL/vLcspv4Jvp
	DdHs45eIbVkyDH+zheKI+nl2oUPMyY7dtHJ4+WeAputxHJLOIEElQa6nI8VRxw+lqXQ==
X-Received: by 2002:a50:970a:: with SMTP id c10mr88646923edb.2.1558522580199;
        Wed, 22 May 2019 03:56:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzj9VptgG0KH4CqpwOjnfr7qHYNq4jDlB4t2i5cY+QaTfFkuzESD+oPyouWT50rVc6klnr
X-Received: by 2002:a50:970a:: with SMTP id c10mr88646881edb.2.1558522579544;
        Wed, 22 May 2019 03:56:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558522579; cv=none;
        d=google.com; s=arc-20160816;
        b=KjqG0ICgKv/pYX/wa7RNuKWsVo4Ae0dJkHpB+GTSsU1AlNLXFM4sHOn9PZ2CZZSD8J
         Qghn4TLPT1+1/zy+w1OjiHJAbneD1gL9YXFVkylk8zmCVpUvoyqf5Pwk2go0eWli7hA2
         ZBYHiEcjfTkbolIQCdX7Fcdb62WvLcyxeBQfWpaT2iBgXWdpHpWpBgoQx2usPgoFrATk
         qKRL3a8XjBCiU16ACnMEItD1QBvk6CkbLz5Ckz/Kx+dSCjAV7YTP4jDVpSovW6HfAeBu
         TjXp15KHvXYhYOEyzfzryvkM7pvQCh0Q6bLkIxvUDb5YkaeZRI+S3xs6zYTee7pFTRrS
         r/4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+Mm7B1NAcDwkPHWQyE15lGI1eeyxaVtjrsxpzZh2l9U=;
        b=wWP0t0p1w30T/g0ed+dQn8Zc84IkfhTYo+ax1sSXCotC66TzymKxe+WFV9keveLfAd
         2epiaUoRt5VS4kIA9rUplSwSdil28YBu4zMtCkfjUNOdQaekdusZS3wek5zb7mSLwXfl
         ngpbBP0OfoFAgaRxHyjB08/QEwDy8etVThflutTCZm84u1Z+d1Lo0OqD70jDao4ws948
         FJ1Mjem6ZTkvDh9nCwAxrdyxc2XYHGcPtge6y2fYfUMq5c3po3QjIBwpsmCThQ/M7aSt
         R1vBHK9ReSrU0MKg6e4k5QZ7+uPdjCaTMoFcR+9GbsvNC8DSOmQGtCNNk01TgcEo/VtE
         s4+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h36si351017edb.397.2019.05.22.03.56.19
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 03:56:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7F9AA341;
	Wed, 22 May 2019 03:56:18 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AD2E53F575;
	Wed, 22 May 2019 03:56:12 -0700 (PDT)
Date: Wed, 22 May 2019 11:56:10 +0100
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
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 04/17] mm: add ksys_ wrappers to memory syscalls
Message-ID: <20190522105609.jpmaiq3adyh6apx2@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <55496bc72542ec14c4c8de23a4df235644013911.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55496bc72542ec14c4c8de23a4df235644013911.1557160186.git.andreyknvl@google.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:50PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> This patch adds ksys_ wrappers to the following memory syscalls:
> 
> brk, get_mempolicy (renamed kernel_get_mempolicy -> ksys_get_mempolicy),
> madvise, mbind (renamed kernel_mbind -> ksys_mbind), mincore,
> mlock (renamed do_mlock -> ksys_mlock), mlock2, mmap_pgoff,
> mprotect (renamed do_mprotect_pkey -> ksys_mprotect_pkey), mremap, msync,
> munlock, munmap, remap_file_pages, shmat, shmdt.
> 
> The next patch in this series will add a custom implementation for these
> syscalls that makes them accept tagged pointers on arm64.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

