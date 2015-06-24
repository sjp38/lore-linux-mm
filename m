Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 36BBE6B0032
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 05:16:53 -0400 (EDT)
Received: by wgck11 with SMTP id k11so30779717wgc.0
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 02:16:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iy7si1769135wic.58.2015.06.24.02.16.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Jun 2015 02:16:51 -0700 (PDT)
Date: Wed, 24 Jun 2015 11:16:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Write throughput impaired by touching dirty_ratio
Message-ID: <20150624091650.GC32756@dhcp22.suse.cz>
References: <1506191513210.2879@stax.localdomain>
 <558A69F8.2080304@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <558A69F8.2080304@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hills <mark@xwax.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 24-06-15 10:27:36, Vlastimil Babka wrote:
> [add some CC's]
> 
> On 06/19/2015 05:16 PM, Mark Hills wrote:
[...]
> > The system is an HP xw6600, running i686 kernel. This happens whether 

How many CPUs does the machine have?

> > internal SATA HDD, SSD or external USB drive is used. I first saw this on 
> > kernel 4.0.4, and 4.0.5 is also affected.

OK so this is 32b kernel which might be the most important part. What is
the value of /proc/sys/vm/highmem_is_dirtyable? Also how does your low
mem vs higmem look when you are setting the ratio (cat /proc/zoneinfo)?

It seems Vlastimil is right and a bogus ratelimit_pages is calculated
and your writers are throttled every few pages.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
