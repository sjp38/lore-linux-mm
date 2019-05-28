Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78C30C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:54:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 230E4206BA
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:54:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 230E4206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ADA36B0276; Tue, 28 May 2019 10:54:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 738726B0279; Tue, 28 May 2019 10:54:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D7776B027A; Tue, 28 May 2019 10:54:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9986B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 10:54:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p14so33536594edc.4
        for <linux-mm@kvack.org>; Tue, 28 May 2019 07:54:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8d74jFy6weW1l3n6RJracSmjeKOey4N+g70LbZoZ0uo=;
        b=WMYZ7cJWbhYwpGyikJXQsJVZ1IAGGrAYUNnNdJ/0NN1owtaA1ulhV3m06YX9BHIsy+
         Jr8bMcLndjKxezKsQcil+1OrsjlcqBEK6lvzzZSCgSYE87IT1CaGGuVPceY6My0duuLy
         ME+LmVCfsmwsS5vBNLZgMtJa3rl+LoCQbZXXPoxzrq89QxnzIozg2ii8IetSObu43yJ4
         ZMwysXZIabLyvd0guzcYfF2LwYmdy74hHC5qCDvNQT8812p39aUIc0MK9IBTr53U4FNd
         lISRWsmAlG7/q/1doKc+8SsgI8rKRKaXYEOQWc+nJPr/WHUHnS0D/OoVZMbaE6Vlq+NC
         6Cfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of andrew.murray@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=andrew.murray@arm.com
X-Gm-Message-State: APjAAAWeDLPh0XVnPOazrbj6ZqsXGFKqzYGsC648cLrktQ2LbfCzlNvs
	+kMppDOuw0miNRcBvMvBqDJZAAZ2FMg7bLQmzbUxsdDEs/RfhLPfMWvUpwpMDkyW0Bxw0vcEbDF
	KJY/kSPCujckYMVLT9pd1M2fLCpwno6SylFW9SlreaGZLaB4Lzb90Q2FriF7Jj3HH6A==
X-Received: by 2002:a50:a53c:: with SMTP id y57mr3200434edb.17.1559055256540;
        Tue, 28 May 2019 07:54:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/ggY5EeVkXbu5JzN7zHmHf8QFaIu1adjuExm4gqC/VuQ34V/WQJdDrEwbt56uvqz9ZVCl
X-Received: by 2002:a50:a53c:: with SMTP id y57mr3200345edb.17.1559055255586;
        Tue, 28 May 2019 07:54:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559055255; cv=none;
        d=google.com; s=arc-20160816;
        b=ormyA7ULcO/IWKPujEGHMj9pvRAC8ANHyvMCgnRfy+F1MdK1D7JkSUYEdJndMld5D+
         iE446fs5IqC/CBFxVSAUONGrW4efKE+g35IHxE7AHePejW5rbCal2LXkvDVrj/FG05tr
         b5zPyvvKvlbBgsKlfuJ2fcQhFfOtygxQT+vAhDfkxu0/P+Bdk08d1MFT1wbYVKO8z5YG
         fmo0kKtNIB1idOKXdnl4NZ4knGZfKdFOcUrz//fKMA3Kg/c/txV3vN5vHc/94fSffOaF
         U781VwAT8L10f25ybn09y4SEM5lFhQf5FzVG9NKwvbwbNJlIoeKY0817i6F5lbDfhqkV
         Z4hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8d74jFy6weW1l3n6RJracSmjeKOey4N+g70LbZoZ0uo=;
        b=aZQZKjX6VYUxhJ56RyZTSUOOia9pcC9ZF2Du+mAVm7tfjiO3Vb7dnSWNIUWYCtvbg+
         M4j9BjN7eFCNGG5bdbP+wiIbdyx+bUtPc391Tb/w+kBt7UKDq0GEHreEixtwBVn1A/Te
         2nMdasG2lzAwoXQA4CAkMadK42GvFZdRS9gOQl0B3D9Q5XLDJ0RnmZvkoOVhyVUTlwhX
         lH9zYgU5mZTPa1nF0ysEGs6f8t6DYYjRuCo6J5sU4WVq14isO8rk8JolYVwzb444JW4f
         slcnhd0WqNNtPhsA7SqPHRYXp6apyr96KuPPKDJ/d2M9GteweJn5iCg4dtWs4xNkr5IG
         dp+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of andrew.murray@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=andrew.murray@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b20si3724915ede.282.2019.05.28.07.54.14
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 07:54:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of andrew.murray@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of andrew.murray@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=andrew.murray@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F18CC80D;
	Tue, 28 May 2019 07:54:13 -0700 (PDT)
Received: from localhost (unknown [10.37.6.20])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 689083F5AF;
	Tue, 28 May 2019 07:54:13 -0700 (PDT)
Date: Tue, 28 May 2019 15:54:11 +0100
From: Andrew Murray <andrew.murray@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
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
Message-ID: <20190528145411.GA709@e119886-lin.cambridge.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190527143719.GA59948@MBP.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527143719.GA59948@MBP.local>
User-Agent: Mutt/1.10.1+81 (426a6c1) (2018-08-26)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 03:37:20PM +0100, Catalin Marinas wrote:
> On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> > 
> > This patch allows tagged pointers to be passed to the following memory
> > syscalls: brk, get_mempolicy, madvise, mbind, mincore, mlock, mlock2,
> > mmap, mmap_pgoff, mprotect, mremap, msync, munlock, munmap,
> > remap_file_pages, shmat and shmdt.
> > 
> > This is done by untagging pointers passed to these syscalls in the
> > prologues of their handlers.
> > 
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> 
> Actually, I don't think any of these wrappers get called (have you
> tested this patch?). Following commit 4378a7d4be30 ("arm64: implement
> syscall wrappers"), I think we have other macro names for overriding the
> sys_* ones.

What is the value in adding these wrappers?

The untagged_addr macro is defined for all in linux/mm.h and these patches
already use untagged_addr in generic code. Thus adding a few more
untagged_addr in the generic syscall handlers (which turn to a nop for most)
is surely better than adding wrappers?

Even if other architectures implement untagged_addr in the future it would
be more consistent if they untagged in the same places and thus not adding
these wrappers enforces that.

Thanks,

Andrew Murray

> 
> -- 
> Catalin
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

