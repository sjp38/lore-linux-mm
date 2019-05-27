Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB7C0C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 14:37:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B975B2182B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 14:37:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B975B2182B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58A226B0003; Mon, 27 May 2019 10:37:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53A846B0280; Mon, 27 May 2019 10:37:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DC3B6B0281; Mon, 27 May 2019 10:37:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E36AC6B0003
	for <linux-mm@kvack.org>; Mon, 27 May 2019 10:37:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d15so28340425edm.7
        for <linux-mm@kvack.org>; Mon, 27 May 2019 07:37:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m1a9/BBjk4boCMxy+N5e0MGffssE2NDgewBYpU/5jKw=;
        b=nqKovLqeqyu776Py6B5qtutmUtq6yWVrNCdAvfFLomK2tWo2E5mezO7cZjuS90Ts89
         UPeLt5XgIYjTka6lD1gEg9d6QoFGxFDrpDcaAgv9jJsmUlbA1IqVevwtAmG9rb3e6ovW
         vV7T7RU6VLCfRvG3OLEjXhj9dUlyuF2cR6FDgUu/7KZFcCSFewApDpBIidFTjtgLPe6F
         yBN18k/qD7TDdjZtll/ovf3Z4DMLJANu3tSXpd75H9GfgVJHD6ZZ+f8Jqol4pFeUfmfT
         A580wlXa4WX1XVS/8tGbLEaQgUqm+Da87ABzBaypvgs8VCaEflb46uV9fbPxIR6FC+iK
         0rlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV2yWxz/7T3tOWzqy7JOUFD7QJTTqsHnZoylpHbGGif8pK3AjJT
	aDZwTKpdo1OZqoqx7uPjTkmZ649gjU9mik+jUhrCSzUQKGHkrskuqwkizOHEeLJYdXfx8GtqvMo
	x5BFfCvUAqyc/zdHdzjBETB6xjVGMXTzhtT/XXRzsNsxaDa0vVr1JWw1/PeRJ/WUJjw==
X-Received: by 2002:aa7:c596:: with SMTP id g22mr124100155edq.32.1558967851442;
        Mon, 27 May 2019 07:37:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyutAMz/oxMT0j8DWutMULTA/4c4OWA7jLJ5yrLn/RD5yRrEwD7CRQV6zuXcN1K3XLvn5OH
X-Received: by 2002:aa7:c596:: with SMTP id g22mr124100064edq.32.1558967850603;
        Mon, 27 May 2019 07:37:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558967850; cv=none;
        d=google.com; s=arc-20160816;
        b=gYZBlGJEPPsOnq94KTbbEgdCI6QhEQ6Yk5DRSsE1yN5/wjvj7zlVAdkqDCMD6m2Zyf
         87Bwq7qEOwCqDi39ldaty2bOH0aNZOaThBbLFzthbITqUxcFgnhibKlmB0jWTog1Jgaq
         In8tox5bN1YxcCB6MlxVW8h+iLCycYQ7PgTecBCYeZdZkqXGKq6czhi2/oIF6Fyx5vAv
         Kd5Ju12vqEYmdmeHfI/XXwUuhxf4xIY95MLtNF18/fxiws8ob9XyzFairluVcS+miBSC
         4a2sV5H6nLz9Q9e26vNQexhAdURFaXlYgYBS8iGg+b4vWYEZyOFe+1YBMtiyDhlc64GN
         Uoag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=m1a9/BBjk4boCMxy+N5e0MGffssE2NDgewBYpU/5jKw=;
        b=spKBsB1tZaWyzISFokEOSa7DmRUxQr3s0PodCcrh6mzvSjh0JZBTK0aAaOu5wG4xv2
         FhoJGaK/8ebIzSGa6AwqCeUexW4L2InC5CqCGVJ/7+Gpmv3KVCUSnzvCZYxVIOisfIxL
         YyU+OWbcwhWe5D5Tx012HvM2m8zYhKFzkhdar2VtS+RE1Z3IubQiAEXXFoJvgWfOZHGU
         GMOA5CYe3zXsP0i9oMeLixhgsKW+npUp505T8EUQCTs4cFc0FPHt78DtdKz/l0/oGQQI
         aZuTs6nhX08z230J6bv8uvFFqpZHFk9OWSfJMYtQHj8i6pg8ffkImkBVidrflwXqHwBs
         dVQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j38si8904864eda.260.2019.05.27.07.37.30
        for <linux-mm@kvack.org>;
        Mon, 27 May 2019 07:37:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5825FA78;
	Mon, 27 May 2019 07:37:29 -0700 (PDT)
Received: from MBP.local (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 765183F59C;
	Mon, 27 May 2019 07:37:23 -0700 (PDT)
Date: Mon, 27 May 2019 15:37:20 +0100
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
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190527143719.GA59948@MBP.local>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> This patch allows tagged pointers to be passed to the following memory
> syscalls: brk, get_mempolicy, madvise, mbind, mincore, mlock, mlock2,
> mmap, mmap_pgoff, mprotect, mremap, msync, munlock, munmap,
> remap_file_pages, shmat and shmdt.
> 
> This is done by untagging pointers passed to these syscalls in the
> prologues of their handlers.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Actually, I don't think any of these wrappers get called (have you
tested this patch?). Following commit 4378a7d4be30 ("arm64: implement
syscall wrappers"), I think we have other macro names for overriding the
sys_* ones.

-- 
Catalin

