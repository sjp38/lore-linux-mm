Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B15726B078A
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 05:29:30 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a26-v6so3337341pgw.7
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 02:29:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e6-v6si1756772pgh.50.2018.08.17.02.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 02:29:29 -0700 (PDT)
Date: Fri, 17 Aug 2018 11:29:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
Message-ID: <20180817092923.GB709@dhcp22.suse.cz>
References: <328204943.8183321.1534496501208.ref@mail.yahoo.com>
 <328204943.8183321.1534496501208@mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <328204943.8183321.1534496501208@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry <reserv0@yahoo.com>
Cc: Alkis Georgopoulos <alkisg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 17-08-18 09:01:41, Thierry wrote:
> Bug still present for 32 bits kernel in v4.18.1, and now, v4.1 (last
> working Linux kernel for 32 bits machines with 16Gb or more RAM) has
> gone unmaintained...

Have you tried to set highmem_is_dirtyable as suggested elsewhere?

I would like to stress out that 16GB with 32b kernels doesn't play
really nice. Even small changes (larger kernel memory footprint) can
lead to all sorts of problems. I would really recommend using 64b
kernels instead. There shouldn't be any real reason to stick with 32b
highmem based kernel for such a large beast. I strongly doubt the cpu
itself would be 32b only.

-- 
Michal Hocko
SUSE Labs
