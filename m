Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A53B56B02F3
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:13:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z45so10286384wrb.13
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 00:13:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y23si3924333wrc.2.2017.06.23.00.13.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 00:13:27 -0700 (PDT)
Date: Fri, 23 Jun 2017 09:13:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
Message-ID: <20170623071324.GD5308@dhcp22.suse.cz>
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alkis Georgopoulos <alkisg@gmail.com>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 22-06-17 12:37:36, Andrew Morton wrote:
[...]
> > Me and a lot of other users have an issue where disk writes start fast (e.g.
> > 200 MB/sec), but after intensive disk usage, they end up 100+ times slower
> > (e.g. 2 MB/sec), and never get fast again until we run "echo 3 >
> > /proc/sys/vm/drop_caches".

What is your dirty limit configuration. Is your highmem dirtyable
(highmem_is_dirtyable)?

> > This issue happens on systems with any 4.x kernel, i386 arch, 16+ GB RAM.
> > It doesn't happen if we use 3.x kernels (i.e. it's a regression) or any 64bit
> > kernels (i.e. it only affects i386).

I remember we've had some changes in the way how the dirty memory is
throttled and 32b would be more sensitive to those changes. Anyway, I
would _strongly_ discourage you from using 32b kernels with that much of
memory. You are going to hit walls constantly and many of those issues
will be inherent. Some of them less so but rather non-trivial to fix
without regressing somewhere else. You can tune your system somehow but
this will be fragile no mater what.

Sorry to say that but 32b systems with tons of memory are far from
priority of most mm people. Just use 64b kernel. There are more pressing
problems to deal with.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
