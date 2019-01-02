Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E82A58E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 07:24:53 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t7so31689763edr.21
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 04:24:53 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id a7si513504edl.383.2019.01.02.04.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 04:24:52 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 66B90B89DA
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 12:24:52 +0000 (GMT)
Date: Wed, 2 Jan 2019 12:24:50 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: compaction.c: Propagate return value upstream
Message-ID: <20190102122450.GD31517@techsingularity.net>
References: <20181226194257.11038-1-pakki001@umn.edu>
 <20181227035029.GE20878@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181227035029.GE20878@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Aditya Pakki <pakki001@umn.edu>, kjlu@umn.edu, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Yang Shi <yang.shi@linux.alibaba.com>, Johannes Weiner <hannes@cmpxchg.org>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@infradead.org>

On Wed, Dec 26, 2018 at 07:50:29PM -0800, Matthew Wilcox wrote:
> On Wed, Dec 26, 2018 at 01:42:56PM -0600, Aditya Pakki wrote:
> > In sysctl_extfrag_handler(), proc_dointvec_minmax() can return an
> > error. The fix propagates the error upstream in case of failure.
> 
> Why not just ...
> 
> Mel, Randy?  You seem to have been the prime instigators on this.
> 

Patch seems fine.

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs
