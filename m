Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72F3A6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 05:18:23 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k22so21575694wrk.5
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 02:18:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si4721597wmg.47.2017.04.03.02.18.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 02:18:22 -0700 (PDT)
Date: Mon, 3 Apr 2017 11:18:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] calc_memmap_size() isn't accurate and one suggestion to
 improve
Message-ID: <20170403091818.GI24661@dhcp22.suse.cz>
References: <20170328011137.GA8655@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328011137.GA8655@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mgorman@techsingularity.net, jiang.liu@linux.intel.com, akpm@linux-foundation.org, tj@kernel.org, mingo@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 28-03-17 09:11:37, Wei Yang wrote:
> Hi, masters,
> 
> # What I found
> 
> I found the function calc_memmap_size() may not be that accurate to get the
> pages for memmap.
> 
> The reason is:
> 
> > memmap is allocated on a node base,
> > while the calculation is on a zone base
> 
> This applies both to SPARSEMEM and FLATMEM.
> 
> For example, on my laptop with 6G memory, all the memmap space is allocated
> from ZONE_NORMAL.

Please try to be more specific. Why is this a problem? Are you trying to
fix some bad behavior or you want to make it more optimal?

I am sorry I didn't look closer into your proposal but I am quite busy
and other people are probably in a similar situation. If you want to get
a proper feedback please try to state the problem and be explicit if it
is user observable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
