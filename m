Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83E076B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:34:55 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c5so4187600wmi.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 05:34:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94si6542277wrf.7.2017.03.16.05.34.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 05:34:54 -0700 (PDT)
Date: Thu, 16 Mar 2017 13:34:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: MAP_POPULATE vs. MADV_HUGEPAGES
Message-ID: <20170316123449.GE30508@dhcp22.suse.cz>
References: <e134e521-54eb-9ae0-f379-26f38703478e@scylladb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e134e521-54eb-9ae0-f379-26f38703478e@scylladb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@scylladb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 15-03-17 18:50:32, Avi Kivity wrote:
> A user is trying to allocate 1TB of anonymous memory in parallel on 48 cores
> (4 NUMA nodes).  The kernel ends up spinning in isolate_freepages_block().

Which kernel version is that? What is the THP defrag mode
(/sys/kernel/mm/transparent_hugepage/defrag)?
 
> I thought to help it along by using MAP_POPULATE, but then my MADV_HUGEPAGE
> won't be seen until after mmap() completes, with pages already populated.
> Are MAP_POPULATE and MADV_HUGEPAGE mutually exclusive?

Why do you need MADV_HUGEPAGE?
 
> Is my only option to serialize those memory allocations, and fault in those
> pages manually?  Or perhaps use mlock()?

I am still not 100% sure I see what you are trying to achieve, though.
So you do not want all those processes to contend inside the compaction
while still allocate as many huge pages as possible?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
