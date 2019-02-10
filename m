Return-Path: <SRS0=NdlI=QR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 738C5C282C4
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 00:52:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A37921929
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 00:52:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A37921929
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C832B8E00B8; Sat,  9 Feb 2019 19:52:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C31DB8E00B5; Sat,  9 Feb 2019 19:52:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B22918E00B8; Sat,  9 Feb 2019 19:52:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 844A58E00B5
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 19:52:00 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id e31so2299344qtb.22
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 16:52:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=XJkLelzdLzhK7WMM4z+zshrLTbNUKoX1y7BTB8bNEug=;
        b=ap86TUiwAgH8wnsjWMOdtQlIm6ikikhs5HxvTrKvhD0vCZNyebzchYVWv7DnmjuKbA
         el/c6D3TzSY3p7hwbNqGL43EQW0z6UcJVbUSHsHsavsT5KCbEMxBrP2EtXN0SqEmisk3
         gH51DoigQniHkqiMoe6BB2AfU997cI6Arh7cyZH+cMc0CXVEZAd7eXIwxSS6yEMPLwbf
         BhA1Xw7+5bmmZi0tAqdMEWg0pZ6EaImTAohy7c6tmhuwROp7HUTNxjJSv6HsBBSttiTU
         WgET+MhIWD6eo8qM1iIbUnIJ0ZKZ+dI+/iVO9Q98Tuo1RU+rht20GZ62WP2u0+fnU7hj
         2Aww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubZsdFXvQ4A7PbN22lhd3GNGExEKvnfKuXWoJsTQ99GoM2exlJh
	WOwVyQScH2in8pRU69i9CChG/QfrPtEzKe3k8e1sGKf+OW55Qv9XDXs8xPS1D9ACa6icEsFEw8h
	EJK7hVZF/f/782GvYieX3cK2D0phgEK7bLmWwQQ1+QZKzKpsTy0/E9pxr3EcJd3iVGGVXUaCnTI
	76+txDUY+sqcR1Bguf/c3ngRmQicRt/69qrmNZs+Eka+K2Q+ZtY1Zd5V0U6XsWfq6dJ2kF5L5UC
	2oG8h9BWVADAmLxZYkx556HiftW89W5iNhvG/CaIDt2ADXfTYSAoq6C5YC23zwwsSZBvbLLYB7h
	YNo44g3TkuiSk+utJWfNQmgnjKHpRfDB7F+aGEGlrHTtSQYHTF9Dsa25UY9/LNiapjiGk6iJy4N
	N
X-Received: by 2002:a37:93c3:: with SMTP id v186mr21129786qkd.285.1549759920295;
        Sat, 09 Feb 2019 16:52:00 -0800 (PST)
X-Received: by 2002:a37:93c3:: with SMTP id v186mr21129770qkd.285.1549759919650;
        Sat, 09 Feb 2019 16:51:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549759919; cv=none;
        d=google.com; s=arc-20160816;
        b=Ax8t5QeHloUabLyb1+XzHOuXEk/GJ8fLBc/d4h7ykjxwVjBMCFZTqytpxOAC7QkkEV
         6Ap9Y5OHsSrmqAKNZLdqQ51+6On5z1aG3T8pCq2T3ZRSRw0JA30IgUthTPvH2wc0pTVd
         nB4GIaBdL/nr0m/pm0Z6vHcK86V8oK62P2sgnVP4v51ARv1fX8+Ly14sUHDLPKiZuUBB
         unz2rjciLceOEMgDZCeJhHyzS28GV4zdgZU8VX/U/q4UJiwe3uh6F0tK63/tyiDyPd+t
         f1eYiJzLMDnc5Nd08nzv9+3pFRGhnR52zO1uWaEvJgre4rNRljpq4RSc3hsu3o8k1v1W
         QoUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=XJkLelzdLzhK7WMM4z+zshrLTbNUKoX1y7BTB8bNEug=;
        b=vBev9I8d/hKwx415KZ+bk6fUL5hjuL0iWuLBw1LoMSjjVq6zn4XDjSYeggQ/9h3JnV
         6FE/rTGsUsd401ybua2NkYsO24LHIRc4peTe0tDWCwYkhDm/SWetzZP28/wgELFcqbTx
         bFU+rh8SytREUjgyF6zUcGbDcM4ybCzS/KBw2UsGUOUMUqWeKYyvdN03OyAWG9Z59+Sp
         e54So9eYImvfrnX1Bdw6S5RjwNBSpP6MOpMT76q9+Rt8SErJZYWqq+cGt7IE6ohfjWng
         zAx8uQUcryIdMXUEehT3/c/NVpHiXCTHnazk1uYp0JKyW3i5I7oYRHGC7AGzU/u1wFiX
         GMJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14sor1903568qvn.13.2019.02.09.16.51.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Feb 2019 16:51:59 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: AHgI3IZTmPLlMBxSzkSawrG90tnOTcF+/r4MRX0lJPE9fQXEMCoIjJgJWuQBpx666vPlTv3Zzrm7tg==
X-Received: by 2002:a0c:8542:: with SMTP id n60mr21644167qva.205.1549759919435;
        Sat, 09 Feb 2019 16:51:59 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id w123sm19025314qkw.80.2019.02.09.16.51.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Feb 2019 16:51:58 -0800 (PST)
Date: Sat, 9 Feb 2019 19:51:56 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com,
	x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	pbonzini@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org
Subject: Re: [RFC PATCH 0/4] kvm: Report unused guest pages to host
Message-ID: <20190209194940-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204181118.12095.38300.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 10:15:33AM -0800, Alexander Duyck wrote:
> This patch set provides a mechanism by which guests can notify the host of
> pages that are not currently in use. Using this data a KVM host can more
> easily balance memory workloads between guests and improve overall system
> performance by avoiding unnecessary writing of unused pages to swap.

There's an obvious overlap with Nilal's work and already merged Wei's
work here.  So please Cc people reviewing Nilal's and Wei's
patches.


> In order to support this I have added a new hypercall to provided unused
> page hints and made use of mechanisms currently used by PowerPC and s390
> architectures to provide those hints. To reduce the overhead of this call
> I am only using it per huge page instead of of doing a notification per 4K
> page. By doing this we can avoid the expense of fragmenting higher order
> pages, and reduce overall cost for the hypercall as it will only be
> performed once per huge page.
> 
> Because we are limiting this to huge pages it was necessary to add a
> secondary location where we make the call as the buddy allocator can merge
> smaller pages into a higher order huge page.
> 
> This approach is not usable in all cases. Specifically, when KVM direct
> device assignment is used, the memory for a guest is permanently assigned
> to physical pages in order to support DMA from the assigned device. In
> this case we cannot give the pages back, so the hypercall is disabled by
> the host.
> 
> Another situation that can lead to issues is if the page were accessed
> immediately after free. For example, if page poisoning is enabled the
> guest will populate the page *after* freeing it. In this case it does not
> make sense to provide a hint about the page being freed so we do not
> perform the hypercalls from the guest if this functionality is enabled.
> 
> My testing up till now has consisted of setting up 4 8GB VMs on a system
> with 32GB of memory and 4GB of swap. To stress the memory on the system I
> would run "memhog 8G" sequentially on each of the guests and observe how
> long it took to complete the run. The observed behavior is that on the
> systems with these patches applied in both the guest and on the host I was
> able to complete the test with a time of 5 to 7 seconds per guest. On a
> system without these patches the time ranged from 7 to 49 seconds per
> guest. I am assuming the variability is due to time being spent writing
> pages out to disk in order to free up space for the guest.
> 
> ---
> 
> Alexander Duyck (4):
>       madvise: Expose ability to set dontneed from kernel
>       kvm: Add host side support for free memory hints
>       kvm: Add guest side support for free memory hints
>       mm: Add merge page notifier
> 
> 
>  Documentation/virtual/kvm/cpuid.txt      |    4 ++
>  Documentation/virtual/kvm/hypercalls.txt |   14 ++++++++
>  arch/x86/include/asm/page.h              |   25 +++++++++++++++
>  arch/x86/include/uapi/asm/kvm_para.h     |    3 ++
>  arch/x86/kernel/kvm.c                    |   51 ++++++++++++++++++++++++++++++
>  arch/x86/kvm/cpuid.c                     |    6 +++-
>  arch/x86/kvm/x86.c                       |   35 +++++++++++++++++++++
>  include/linux/gfp.h                      |    4 ++
>  include/linux/mm.h                       |    2 +
>  include/uapi/linux/kvm_para.h            |    1 +
>  mm/madvise.c                             |   13 +++++++-
>  mm/page_alloc.c                          |    2 +
>  12 files changed, 158 insertions(+), 2 deletions(-)
> 
> --

