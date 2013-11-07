Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id DCB656B0180
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 16:52:24 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1229497pab.22
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 13:52:24 -0800 (PST)
Received: from psmtp.com ([74.125.245.184])
        by mx.google.com with SMTP id ar5si3967457pbd.242.2013.11.07.13.52.22
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 13:52:23 -0800 (PST)
Date: Thu, 7 Nov 2013 15:52:28 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131107215228.GA4236@sgi.com>
References: <20131016155429.GP25735@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131016155429.GP25735@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Wed, Oct 16, 2013 at 10:54:29AM -0500, Alex Thorlton wrote:
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
> I get intermittent segfaults when running the memscale test that we've
> been using to test some of the THP changes.  Here's a link to the test:
> 
> ftp://shell.sgi.com/collect/memscale/

For anyone who's interested, this test has been moved to:

http://oss.sgi.com/projects/memtests/thp_memscale.tar.gz

It should remain there permanently.

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
> At this point, I'm not familiar enough with NUMA balancing code to know
> what could be causing this, and we don't typically run with NUMA
> balancing on, so I don't see this in my everyday testing, but I felt
> that it was definitely worth bringing up.
> 
> If anybody has any ideas of where I could poke around to find a
> solution, please let me know.
> 
> - Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
