Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9974E6B000D
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 04:05:52 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t1-v6so18085733plb.5
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 01:05:52 -0700 (PDT)
Received: from lgeamrelo12.lge.com (lgeamrelo12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id r30si5146171pgu.587.2018.04.05.01.05.51
        for <linux-mm@kvack.org>;
        Thu, 05 Apr 2018 01:05:51 -0700 (PDT)
Date: Thu, 5 Apr 2018 17:05:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/thp: don't count ZONE_MOVABLE as the target for
 freepage reserving
Message-ID: <20180405080539.GA631@js1304-desktop>
References: <1522913236-15776-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20180405075753.GZ6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405075753.GZ6312@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 05, 2018 at 09:57:53AM +0200, Michal Hocko wrote:
> On Thu 05-04-18 16:27:16, Joonsoo Kim wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > ZONE_MOVABLE only has movable pages so we don't need to keep enough
> > freepages to avoid or deal with fragmentation. So, don't count it.
> > 
> > This changes min_free_kbytes and thus min_watermark greatly
> > if ZONE_MOVABLE is used. It will make the user uses more memory.
> 
> OK, but why does it matter. Has anybody seen this as an issue?

There was a regression report for CMA patchset and I think that it is
related to this problem. CMA patchset makes the system uses one more
zone (ZONE_MOVABLE) and then increase min_free_kbytes. It reduces
usable memory and it could cause regression.

http://lkml.kernel.org/r/20180102063528.GG30397@yexl-desktop

Thanks.
