Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E04BDC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 10:56:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A58862171F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 10:56:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A58862171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45CC66B0003; Tue, 23 Jul 2019 06:56:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E8B46B0005; Tue, 23 Jul 2019 06:56:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AE498E0002; Tue, 23 Jul 2019 06:56:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CEA966B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:56:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so28060857edb.1
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 03:56:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=o9oNm7CwXHUBKBZ/7NRk/JHUCGZiNcFhoOBeZa1q+Ug=;
        b=DmU5j/ftElGCvZOOtxJztHO37bW9fLpE4jTFhpCRA721R3F44HycHle2BUAvdeKdLr
         DkTupXB5hmtyp3kHn74bkGWJSo1LxWZAJKplM9ZX7zNhgGo2ZSIsYZwthqqp77m/pmH9
         sPOplwg3HzL7fYRHEsYNaPuTPlRTIMpk1RWvXWCIMDtXEUKMw5Qj12qyI7na0h41wHOg
         huaT0As71nJPMlLiPmoOhetwbMHcvT09ahVOP+CgVVsnQ9VdaRbVGz/GUfYa4olk9GkZ
         cv4FcFSfsbmKQ+2FxmsKPrHXZ5MVVt8KOEwVlSwkyJyh/hhs3mkPwtHPhpiMH2l/fmoH
         HVTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAXyxcDMypVzdyShyE3fD+Xrl3jZT6GNgVwD859MTWqkDosjiwXi
	L1PTyEVfKkUfevKjdwVyn+211FXMuLnBhbnOdzN5Le2lSX73ikvnrzjsQYO4m2lvQXAm3bndMl0
	Mswt+A0kBZX8eeF6cCSzFkyQsak11NSVGSKV3NhqEokx5/P/Zs4fpNaUM3MyCckCSlw==
X-Received: by 2002:a50:9107:: with SMTP id e7mr65703367eda.280.1563879408394;
        Tue, 23 Jul 2019 03:56:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaqWvrCQ2oIN6xbh8LYC71zCC7nHEzYc1gdUaf/sEUbRgm9d2L4imz2YcsKThEnao6fbYY
X-Received: by 2002:a50:9107:: with SMTP id e7mr65703301eda.280.1563879407435;
        Tue, 23 Jul 2019 03:56:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563879407; cv=none;
        d=google.com; s=arc-20160816;
        b=h4psSTj3QEyoAHATIAEJAwrXrYGHs+QfbqUDPVBBe2Gujk0JPwZZTyQ2PcDHB4l8O5
         XdiCRX4ga5TXhV5sqz6HPLmneJ1QhIT2PCUuStGcTXUDnmk+gU05cFLByqB//azh4MWp
         JZqD/Mncc6K+1Hu45hXEqgSwwWArKAauB5ylcb3myNFNhjoWSr9gSZuuPutuPMjyfkwt
         GjWS9/gbKzRdeG+sdc7hyBaBxy0dSCE+jTWDlBwCr5JV6kUNTBmzSDuEqlrG8YicUa2J
         kPB1RiZB0N1/T4tys4OnYP0NYQJiCY6HoRLVRWMNkoLUKivdjgrvEHoXD/rsXTGh5POx
         1ocA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=o9oNm7CwXHUBKBZ/7NRk/JHUCGZiNcFhoOBeZa1q+Ug=;
        b=SJYRW1YbpqOCF2z5v3P61+N3gdVAi0jlTzCz6Om8fAzcb2RYlId71c380v3XPNXORj
         Sl9Xze6RM2CoIs18K41mDNrJtV1RJroEgcaPf3xR+RqRu7nus6b88lqMUy1CopXB0CWd
         bTliCeNx5dmX7+Z+ODmcwhL7JFBze0kpEx/1T3Sw2TGd5axMUySxYWMqhi+gYi9NxIb8
         VDM9dDCRfK6LGaLdfaa7X+E3F3oOYUXErSBIvW0zs21kugGI3dJ0GBbfVZkOfosfWHnQ
         3qB+GwUia1PMIUC7T27gdy+wB+bLbqlskY090UUKYwwJ/FSu7/2r+Bu8/FsRBO5CBmS9
         KEdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id r55si6339551edd.36.2019.07.23.03.56.46
        for <linux-mm@kvack.org>;
        Tue, 23 Jul 2019 03:56:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 64A5D337;
	Tue, 23 Jul 2019 03:56:46 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E61D53F71A;
	Tue, 23 Jul 2019 03:56:43 -0700 (PDT)
Date: Tue, 23 Jul 2019 11:56:36 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	catalin.marinas@arm.com, will.deacon@arm.com, mhocko@suse.com,
	ira.weiny@intel.com, david@redhat.com, cai@lca.pw,
	logang@deltatee.com, james.morse@arm.com, cpandya@codeaurora.org,
	arunks@codeaurora.org, dan.j.williams@intel.com,
	mgorman@techsingularity.net, osalvador@suse.de,
	ard.biesheuvel@arm.com, steve.capper@arm.com
Subject: Re: [PATCH V6 RESEND 0/3] arm64/mm: Enable memory hot remove
Message-ID: <20190723105636.GA5004@lakrids.cambridge.arm.com>
References: <1563171470-3117-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563171470-3117-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anshuman,

On Mon, Jul 15, 2019 at 11:47:47AM +0530, Anshuman Khandual wrote:
> This series enables memory hot remove on arm64 after fixing a memblock
> removal ordering problem in generic try_remove_memory() and a possible
> arm64 platform specific kernel page table race condition. This series
> is based on linux-next (next-20190712).
> 
> Concurrent vmalloc() and hot-remove conflict:
> 
> As pointed out earlier on the v5 thread [2] there can be potential conflict
> between concurrent vmalloc() and memory hot-remove operation. This can be
> solved or at least avoided with some possible methods. The problem here is
> caused by inadequate locking in vmalloc() which protects installation of a
> page table page but not the walk or the leaf entry modification.
> 
> Option 1: Making locking in vmalloc() adequate
> 
> Current locking scheme protects installation of page table pages but not the
> page table walk or leaf entry creation which can conflict with hot-remove.
> This scheme is sufficient for now as vmalloc() works on mutually exclusive
> ranges which can proceed concurrently only if their shared page table pages
> can be created while inside the lock. It achieves performance improvement
> which will be compromised if entire vmalloc() operation (even if with some
> optimization) has to be completed under a lock.
> 
> Option 2: Making sure hot-remove does not happen during vmalloc()
> 
> Take mem_hotplug_lock in read mode through [get|put]_online_mems() constructs
> for the entire duration of vmalloc(). It protects from concurrent memory hot
> remove operation and does not add any significant overhead to other concurrent
> vmalloc() threads. It solves the problem in right way unless we do not want to
> extend the usage of mem_hotplug_lock in generic MM.
> 
> Option 3: Memory hot-remove does not free (conflicting) page table pages
> 
> Don't not free page table pages (if any) for vmemmap mappings after unmapping
> it's virtual range. The only downside here is that some page table pages might
> remain empty and unused until next memory hot-add operation of the same memory
> range.
> 
> Option 4: Dont let vmalloc and vmemmap share intermediate page table pages
> 
> The conflict does not arise if vmalloc and vmemap range do not share kernel
> page table pages to start with. If such placement can be ensured in platform
> kernel virtual address layout, this problem can be successfully avoided.
> 
> There are two generic solutions (Option 1 and 2) and two platform specific
> solutions (Options 2 and 3). This series has decided to go with (Option 3)
> which requires minimum changes while self-contained inside the functionality.

... while also leaking memory, right?

In my view, option 2 or 4 would have been preferable. Were there
specific technical reasons to not go down either of those routes? I'm
not sure that minimizing changes is the right rout given that this same
problem presumably applies to other architectures, which will need to be
fixed.

Do we know why we aren't seeing issues on other architectures? e.g. is
the issue possible but rare (and hence not reported), or masked by
something else (e.g. the layout of the kernel VA space)?

I'd like to solve the underyling issue before we start adding new
functionality.

> Testing:
> 
> Memory hot remove has been tested on arm64 for 4K, 16K, 64K page config
> options with all possible CONFIG_ARM64_VA_BITS and CONFIG_PGTABLE_LEVELS
> combinations. Its only build tested on non-arm64 platforms.

Could you please share how you've tested this?

Having instructions so that I could reproduce this locally would be very
helpful.

Thanks,
Mark.

