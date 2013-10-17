Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id C7FEB6B003B
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 07:31:01 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so2181733pbc.12
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 04:31:01 -0700 (PDT)
Received: by mail-vc0-f179.google.com with SMTP id hz11so31044vcb.24
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 04:30:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131016155429.GP25735@sgi.com>
References: <20131016155429.GP25735@sgi.com>
Date: Thu, 17 Oct 2013 19:30:58 +0800
Message-ID: <CAA_GA1cnzro65e_qZO3WbJAWGM-R6RgpxhogE_SUmFYdQ5A36g@mail.gmail.com>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

Hi Alex,

On Wed, Oct 16, 2013 at 11:54 PM, Alex Thorlton <athorlton@sgi.com> wrote:
> Hi guys,
>
> I ran into a bug a week or so ago, that I believe has something to do
> with NUMA balancing, but I'm having a tough time tracking down exactly
> what is causing it.  When running with the following configuration
> options set:
>
> CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
> CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
> CONFIG_NUMA_BALANCING=y
> # CONFIG_HUGETLBFS is not set
> # CONFIG_HUGETLB_PAGE is not set
>

What's your kernel version?
And did you enable CONFIG_TRANSPARENT_HUGEPAGE ?

> I get intermittent segfaults when running the memscale test that we've
> been using to test some of the THP changes.  Here's a link to the test:
>
> ftp://shell.sgi.com/collect/memscale/
>
> I typically run the test with a line similar to this:
>
> ./thp_memscale -C 0 -m 0 -c <cores> -b <memory>
>
> Where <cores> is the number of cores to spawn threads on, and <memory>
> is the amount of memory to reserve from each core.  The <memory> field
> can accept values like 512m or 1g, etc.  I typically run 256 cores and
> 512m, though I think the problem should be reproducable on anything with
> 128+ cores.
>
> The test never seems to have any problems when running with hugetlbfs
> on and NUMA balancing off, but it segfaults every once in a while with
> the config options above.  It seems to occur more frequently, the more
> cores you run on.  It segfaults on about 50% of the runs at 256 cores,
> and on almost every run at 512 cores.  The fewest number of cores I've
> seen a segfault on has been 128, though it seems to be rare on this many
> cores.
>

Could you please attach some logs?

> At this point, I'm not familiar enough with NUMA balancing code to know
> what could be causing this, and we don't typically run with NUMA
> balancing on, so I don't see this in my everyday testing, but I felt
> that it was definitely worth bringing up.
>
> If anybody has any ideas of where I could poke around to find a
> solution, please let me know.
>

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
