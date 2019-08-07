Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 151C2C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:09:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DF5C21872
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:09:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DF5C21872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2DA16B0003; Wed,  7 Aug 2019 18:09:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDF306B0006; Wed,  7 Aug 2019 18:09:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCE166B0007; Wed,  7 Aug 2019 18:09:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9621B6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 18:09:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n9so52945123pgq.4
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 15:09:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vmPkNBgNlFQ9adG63g0GQxKzNCZ9DMpZw6H199DEceM=;
        b=L304Bi1xMl3jvMRhepaa8v6shC5YyqUqG1vPWmYOWJHXB0QROtRSkai8MQHDwnZkhm
         /wt1flWkeYy1wWZeXAmb9PCYZcCOBzz9ODhc5GKDpHkxbB6g0o+k0sHUTA5PEIf0JuGM
         i61Shgg03LopoeSWKmvRxsJcTTzP4IF4eNkWPl/h8h2thXuIGpqhrzHABzwAbwkeUr/Y
         dlLN4Ib7jitq2eIk9qVJagfu7ROCkKzfi+I+F/c5WMOP775FG7QFIDcJeQI4fqxNzSVa
         RQpe9m0S+M0bERiBJuvGYVNsV/Jgd3BJL9h1REp93swsEON0LE1Kfan4qKgIPs/8j7Dy
         mC4w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWTJuKKqqVy/dUh/FWq2SBhoP5YrCoMoJNPRcTH/cvdqnUMI//7
	poW3dR/MF3DEF9sem3jlrVl53Fk8laMFxnOzrHD+g8BSWmcupU/IXSeDMQa/AtTKbbAAy+X5ren
	3IohKqar63m/NbWHDXP7m51NGymy84/BQPl+7iNV267WtwcAqIWcX2kn06qEtQdo=
X-Received: by 2002:a17:902:100a:: with SMTP id b10mr10052985pla.338.1565215770085;
        Wed, 07 Aug 2019 15:09:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJZLk2doJP3qNRt1qyLZxLod1XVoQUmIp9ELfgKd8M10tQrrxDEkkDdo3quqdTyF7B6n9K
X-Received: by 2002:a17:902:100a:: with SMTP id b10mr10052912pla.338.1565215768900;
        Wed, 07 Aug 2019 15:09:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565215768; cv=none;
        d=google.com; s=arc-20160816;
        b=KmIkuL4QU0Dr7Q69IO6x0Gagws76JySdG5UpoIuHxt1hLmOMedcu6tkhq/ErKdYtJh
         b1mStmM4w8/gUtDJltDaDcOPuq++VDuxLCKk6t0tFq87k0qrWYKymA64ZPeDyPS3AFKV
         DWJhWeiVFAdwHtz8wI08n8N8eVm+eglbT6p/9t/vi44GX1avG4FP28yyW5+pXwid/MAC
         MwkKIxQUFJ5s7+lUTTGq4NLFYXFfePLZngStlTqx6o8xzK/ObEmtL5PG0d+HKQu+SHy7
         2uTX5qEwTKQUd0F+z+aXeZCQ/shsc/TGfZQZvhEJ3WPYlGwPykHD+w63DMsid0uaoQXH
         9HNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vmPkNBgNlFQ9adG63g0GQxKzNCZ9DMpZw6H199DEceM=;
        b=lQayR3UbeIQfL3oUHSCWJiYlipGqlkHJeCMHOhy87UL+FqpynAv1+7kyDnkcurhYTB
         t9kENv1KSItyN0UchQeTTiqV6qk8zc4QM3x1OsDvg6ItTYTezhvtEaIXXG5pfiFQv2vo
         gDusQ2HbyDaA5c19zI795UsIjsONabRbtsBt9FAujJKJRAvQk9HkknG2men+hO9ki3ke
         261HpbZuHqgFpwMoB3q1CYD7+Q5Cs6xDa3fhG4/XbzRHAgoHGeAuhsc28ybRzNzFNdP5
         W6OCmjbGjZm4viY7NiXEK9Eo8jYrSfuP7M3HKqNi/IfzqWd9yIqM4Oko4BpUZxujaA7R
         ImuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id r4si56783812pfg.26.2019.08.07.15.09.28
        for <linux-mm@kvack.org>;
        Wed, 07 Aug 2019 15:09:28 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 6B24D43E8B3;
	Thu,  8 Aug 2019 08:09:24 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hvU6T-0005vh-8G; Thu, 08 Aug 2019 08:08:17 +1000
Date: Thu, 8 Aug 2019 08:08:17 +1000
From: Dave Chinner <david@fromorbit.com>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] [Regression, v5.0] mm: boosted kswapd reclaim b0rks
 system cache balance
Message-ID: <20190807220817.GN7777@dread.disaster.area>
References: <20190807091858.2857-1-david@fromorbit.com>
 <20190807093056.GS11812@dhcp22.suse.cz>
 <20190807150316.GL2708@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807150316.GL2708@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=WvVMi4Q-HNuRTT1wiOIA:9
	a=WZxntg31Pt30XY-5:21 a=cyQMZgHOg-pEZ9Yp:21 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 04:03:16PM +0100, Mel Gorman wrote:
> On Wed, Aug 07, 2019 at 11:30:56AM +0200, Michal Hocko wrote:
> > [Cc Mel and Vlastimil as it seems like fallout from 1c30844d2dfe2]
> > 
> 
> More than likely.
> 
> > On Wed 07-08-19 19:18:58, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > When running a simple, steady state 4kB file creation test to
> > > simulate extracting tarballs larger than memory full of small files
> > > into the filesystem, I noticed that once memory fills up the cache
> > > balance goes to hell.
> > > 
> 
> Ok, I'm assuming you are using fsmark with -k to keep files around,
> and -S0 to leave cleaning to the background flush, a number of files per
> iteration to get regular reporting and a total number of iterations to
> fill memory to hit what you're seeing. I've created a configuration that
> should do this but it'll take a long time to run on a local test machine.

./fs_mark  -D  10000  -S0  -n  10000  -s  4096  -L  60 \
-d /mnt/scratch/0  -d  /mnt/scratch/1  -d  /mnt/scratch/2 \
-d /mnt/scratch/3  -d  /mnt/scratch/4  -d  /mnt/scratch/5 \
-d /mnt/scratch/6  -d  /mnt/scratch/7  -d  /mnt/scratch/8 \
-d /mnt/scratch/9  -d  /mnt/scratch/10  -d  /mnt/scratch/11 \
-d /mnt/scratch/12  -d  /mnt/scratch/13  -d  /mnt/scratch/14 \
-d /mnt/scratch/15

This doesn't delete files at all, creates 160,000 files per
iteration in directories of 10,000 files at a time, and runs 60
iterations. It leaves all writeback (data and metadata) to
background kernel mechanisms.

> I'm not 100% certain I guessed right as to get fsmark reports while memory
> fills, it would have to be fewer files so each iteration would have to
> preserve files. If the number of files per iteration is large enough to
> fill memory then the drop in files/sec is not visible from the fs_mark
> output (or we are using different versions). I guess you could just be
> calculating average files/sec over the entire run based on elapsed time.

The files/s average is the average of the fsmark iteration output.
(i.e. the rate at which it creates each group of 160k files).

> 
> > > The workload is creating one dirty cached inode for every dirty
> > > page, both of which should require a single IO each to clean and
> > > reclaim, and creation of inodes is throttled by the rate at which
> > > dirty writeback runs at (via balance dirty pages). Hence the ingest
> > > rate of new cached inodes and page cache pages is identical and
> > > steady. As a result, memory reclaim should quickly find a steady
> > > balance between page cache and inode caches.
> > > 
> > > It doesn't.
> > > 
> > > The moment memory fills, the page cache is reclaimed at a much
> > > faster rate than the inode cache, and evidence suggests taht the
> > > inode cache shrinker is not being called when large batches of pages
> > > are being reclaimed. In roughly the same time period that it takes
> > > to fill memory with 50% pages and 50% slab caches, memory reclaim
> > > reduces the page cache down to just dirty pages and slab caches fill
> > > the entirity of memory.
> > > 
> > > At the point where the page cache is reduced to just the dirty
> > > pages, there is a clear change in write IO patterns. Up to this
> > > point it has been running at a steady 1500 write IOPS for ~200MB/s
> > > of write throughtput (data, journal and metadata).
> 
> As observed by iostat -x or something else? Sum of r/s and w/s would

PCP + live pmcharts. Same as I've done for 15+ years :)

I could look at iostat, but it's much easier to watch graphs run
and then be able to double click on any point and get the actual
value.

I've attached a screen shot of the test machine overview while the
vanilla kernel runs the fsmark test (cpu, iops, IO bandwidth, XFS
create/remove/lookup ops, context switch rate and memory usage) at a
1 second sample rate. You can see the IO patterns change, the
context switch rate go nuts and the CPU usage pattern change when
the page cache hits empty.

> approximate iops but not the breakdown of whether it is data, journal
> or metadata writes.

I have that in other charts - the log chart tells me how many log
IOs are being done (constant 30MB/s in ~150 IOs/sec). And the >1GB/s
IO spike every 30s is the metadata writeback being aggregated into
large IOs by metadata writeback. That doesn't change, either...

> The rest can be inferred from a blktrace but I would
> prefer to replicate your setup as close as possible. If you're not using
> fs_mark to report Files/sec, are you simply monitoring df -i over time?

The way I run fsmark is iterative - the count field tells you how
many inodes it has created...

> > > So I went looking at the code, trying to find places where pages got
> > > reclaimed and the shrinkers weren't called. There's only one -
> > > kswapd doing boosted reclaim as per commit 1c30844d2dfe ("mm: reclaim
> > > small amounts of memory when an external fragmentation event
> > > occurs"). I'm not even using THP or allocating huge pages, so this
> > > code should not be active or having any effect onmemory reclaim at
> > > all, yet the majority of reclaim is being done with "boost" and so
> > > it's not reclaiming slab caches at all. It will only free clean
> > > pages from the LRU.
> > > 
> > > And so when we do run out memory, it switches to normal reclaim,
> > > which hits dirty pages on the LRU and does some shrinker work, too,
> > > but then appears to switch back to boosted reclaim one watermarks
> > > are reached.
> > > 
> > > The patch below restores page cache vs inode cache balance for this
> > > steady state workload. It balances out at about 40% page cache, 60%
> > > slab cache, and sustained performance is 10-15% higher than without
> > > this patch because the IO patterns remain in control of dirty
> > > writeback and the filesystem, not kswapd.
> > > 
> > > Performance with boosted reclaim also running shrinkers over the
> > > same steady state portion of the test as above.
> > > 
> 
> The boosting was not intended to target THP specifically -- it was meant
> to help recover early from any fragmentation-related event for any user
> that might need it. Hence, it's not tied to THP but even with THP
> disabled, the boosting will still take effect.
> 
> One band-aid would be to disable watermark boosting entirely when THP is
> disabled but that feels wrong. However, I would be interested in hearing
> if sysctl vm.watermark_boost_factor=0 has the same effect as your patch.

<runs test>

Ok, it still runs it out of page cache, but it doesn't drive page
cache reclaim as hard once there's none left. The IO patterns are
less peaky, context switch rates are increased from ~3k/s to 15k/s
but remain pretty steady.

Test ran 5s faster and  file rate improved by ~2%. So it's better
once the page cache is largerly fully reclaimed, but it doesn't
prevent the page cache from being reclaimed instead of inodes....


> On that basis, it may justify ripping out the may_shrinkslab logic
> everywhere. The downside is that some microbenchmarks will notice.
> Specifically IO benchmarks that fill memory and reread (particularly
> rereading the metadata via any inode operation) may show reduced
> results.

Sure, but right now benchmarks that rely on page cache being
retained are being screwed over :)

> Such benchmarks can be strongly affected by whether the inode
> information is still memory resident and watermark boosting reduces
> the changes the data is still resident in memory. Technically still a
> regression but a tunable one.

/proc/sys/vm/vfs_cache_pressure is for tuning page cache/inode cache
balance. It should not occur as a side effect of watermark boosting.
Everyone knows about vfs_cache_pressure. Lots of people complain
when it doesn't work, and that's something watermark boosting to
change cache balance does.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

