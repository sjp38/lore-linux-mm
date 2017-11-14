Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4C246B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 03:21:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id s2so19614010pge.19
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 00:21:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a72si12773988pge.529.2017.11.14.00.21.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 00:21:06 -0800 (PST)
Date: Tue, 14 Nov 2017 09:21:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: show stats for non-default hugepage sizes in
 /proc/meminfo
Message-ID: <20171114082103.izrb2jnmlgzdvgfv@dhcp22.suse.cz>
References: <20171113160302.14409-1-guro@fb.com>
 <20171113161102.rieyg55drdqkri6e@dhcp22.suse.cz>
 <20171113163233.GA17016@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171113163233.GA17016@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon 13-11-17 16:33:05, Roman Gushchin wrote:
[...]
> IMO, /proc/meminfo should give a user a high-level overview of memory usage
> in the system, without a need to look into other places. Of course, we always
> have some amount of unaccounted memory, but it shouldn't be measured in Gb,
> as in this case.

Well, this is not so easy. There can be _a lot_ of unaccounted memory.
Gbs is not something unheard of (fs metadata directly allocated by the
page allocator, network buffers, you name it). Unlike those the hugetlb
requires an explicit admin interaction. Especially for the non-default
hugetlb page sizes.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
