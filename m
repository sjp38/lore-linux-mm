Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 543A9C04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:41:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1922E2133F
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:41:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1922E2133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B833D6B0276; Tue, 28 May 2019 11:41:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B32D96B0279; Tue, 28 May 2019 11:41:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AC806B027A; Tue, 28 May 2019 11:41:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9856B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 11:41:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y22so33663470eds.14
        for <linux-mm@kvack.org>; Tue, 28 May 2019 08:41:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=i/OyxepcdI4MhZ78D6qBCBDXaKNkVnp8K4/arB4y6mc=;
        b=asx2ASwGHWmQahOJrelFcffylr1ZYsDWuVmQmGPtGgSeM+CRzpLF1Gwot54J69bI+R
         vtOasUPwGeurMQetgBFVZT2HYtm0VgW5PsVaLXw2c8/Eisn5WzDH7dyPXXC/uiv6zT6E
         SjWV1/ksrV4Pc05YIkZOLlDfEgsICZHrCKHe7xfSQpGEEd+E0OOROrcDM2Kw8J5wo4Ms
         Xx22B/BKd9FWoSDczY3vx3aq9hl6zRlmPf/TigbcXrVtC9HIjHnjxKQfBqBZMsSW5rRQ
         L59Zc9rSkR57OSmgvoc3hOOthYuDZaKomqmzvn6vCpEIpaxOgiJF00MPQm7tE37RIGO4
         i1Iw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUP27QHCpVXGNZtSsgKDdiTjpuccv+znd4ZHEdPI0aphLhdrlwU
	PFjPcTlNnc8CfG5WS6gcsxOaQY/fr9TBoisuwGMF+MDShcrnnbGgA5XTXkbd1glIxybc1Tu98UO
	ovP8w8cbLHsgdMH4H+NQ6xKXfA2E3KfmD9DYeIExy03VPi3J63cbWcsXFW3wjf0LBpg==
X-Received: by 2002:a17:907:20cd:: with SMTP id qq13mr7226733ejb.170.1559058068852;
        Tue, 28 May 2019 08:41:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+33GnYxtz5F3peTXaYuAiQ9J2EkLbImpji12XuorQjQzbSItHWLGT3OKQrBpi3yWBiO0M
X-Received: by 2002:a17:907:20cd:: with SMTP id qq13mr7226640ejb.170.1559058067738;
        Tue, 28 May 2019 08:41:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559058067; cv=none;
        d=google.com; s=arc-20160816;
        b=pn1LWzOqy8YsHRcYx0G5fMb7jnScQCrSjS5MEexx4Yd/U5lgvjZhA2f6yCfu8VboBR
         j0iXmQc3JV22e+VL8HGLt9bbpUX3XeRHbyz7paezE3S7FAXL/6KaZ6ld9L9cH1elcdg9
         2XAmZqkW1Y5yTUR14qKGdgOYRL0E1CON4OHL7+9+GW3Pgb9HKaY3G/AQ4/AvOON3IHpB
         9dMFlCElbzdZtt0iA39UmAL/IBc3eW0kGenxsISo1V7BubD4O9m3JQFh4ck5CK694Dym
         gifR/EpSJEOjlcTcthw6kQH+rCC3q6Hrbc/Ed4GZqTVmmWY6SIAJCueNdpn94fr0d7OC
         95gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=i/OyxepcdI4MhZ78D6qBCBDXaKNkVnp8K4/arB4y6mc=;
        b=BR8DErxjXmhqduJkOUVlWztaqzlVkLYvIZmnXSG51trRI0j1j5mPig2XtnDPaoRUVT
         9JgwGBaUdOA8tUBoXgsYyrHGcIgpsUIZN9fx7kSOeiEg7kIXBMaNp0da+9aMe8QxYWc4
         y/25UxBTUwa3GTDrnwIaGJxtpZABBUWPCGyQlwwK9z46/0327SKs2X4R3glmAA+tI7QK
         gnERyAV8osksint/n8SUoOAJhM0NfZXdgjGaTOqKMb9UNp/AioJpekUsGvqcA8c75ANA
         U4Ag+1+Lj211R7tHkkM72nMmkS6cWXiXtANNpOpLeta1rbQN43AmYzQhGZM6oNIDN0Sb
         LJOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d33si10016005eda.62.2019.05.28.08.41.07
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 08:41:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AE9D7341;
	Tue, 28 May 2019 08:41:06 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 027FD3F59C;
	Tue, 28 May 2019 08:41:00 -0700 (PDT)
Date: Tue, 28 May 2019 16:40:58 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrew Murray <andrew.murray@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, Dmitry Vyukov <dvyukov@google.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>, linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190528154057.GD32006@arrakis.emea.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190527143719.GA59948@MBP.local>
 <20190528145411.GA709@e119886-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528145411.GA709@e119886-lin.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 03:54:11PM +0100, Andrew Murray wrote:
> On Mon, May 27, 2019 at 03:37:20PM +0100, Catalin Marinas wrote:
> > On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > pass tagged user pointers (with the top byte set to something else other
> > > than 0x00) as syscall arguments.
> > > 
> > > This patch allows tagged pointers to be passed to the following memory
> > > syscalls: brk, get_mempolicy, madvise, mbind, mincore, mlock, mlock2,
> > > mmap, mmap_pgoff, mprotect, mremap, msync, munlock, munmap,
> > > remap_file_pages, shmat and shmdt.
> > > 
> > > This is done by untagging pointers passed to these syscalls in the
> > > prologues of their handlers.
> > > 
> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > 
> > Actually, I don't think any of these wrappers get called (have you
> > tested this patch?). Following commit 4378a7d4be30 ("arm64: implement
> > syscall wrappers"), I think we have other macro names for overriding the
> > sys_* ones.
> 
> What is the value in adding these wrappers?

Not much value, initially proposed just to keep the core changes small.
I'm fine with moving them back in the generic code (but see below).

I think another aspect is how we define the ABI. Is allowing tags to
mlock() for example something specific to arm64 or would sparc ADI need
the same? In the absence of other architectures defining such ABI, my
preference would be to keep the wrappers in the arch code.

Assuming sparc won't implement untagged_addr(), we can place the macros
back in the generic code but, as per the review here, we need to be more
restrictive on where we allow tagged addresses. For example, if mmap()
gets a tagged address with MAP_FIXED, is it expected to return the tag?

My thoughts on allowing tags (quick look):

brk - no
get_mempolicy - yes
madvise - yes
mbind - yes
mincore - yes
mlock, mlock2, munlock - yes
mmap - no (we may change this with MTE but not for TBI)
mmap_pgoff - not used on arm64
mprotect - yes
mremap - yes for old_address, no for new_address (on par with mmap)
msync - yes
munmap - probably no (mmap does not return tagged ptrs)
remap_file_pages - no (also deprecated syscall)
shmat, shmdt - shall we allow tagged addresses on shared memory?

The above is only about the TBI ABI while ignoring hardware MTE. For the
latter, we may want to change the mmap() to allow pre-colouring on page
fault which means that munmap()/mprotect() should also support tagged
pointers. Possibly mremap() as well but we need to decide whether it
should allow re-colouring the page (probably no, in which case
old_address and new_address should have the same tag). For some of these
we'll end up with arm64 specific wrappers again, unless sparc ADI adopts
exactly the same ABI restrictions.

-- 
Catalin

