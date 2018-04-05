Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9156B000E
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 04:27:12 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z15so12970266wrh.10
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 01:27:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 125si3547130wmr.31.2018.04.05.01.27.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 01:27:11 -0700 (PDT)
Date: Thu, 5 Apr 2018 10:27:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/thp: don't count ZONE_MOVABLE as the target for
 freepage reserving
Message-ID: <20180405082708.GA6312@dhcp22.suse.cz>
References: <1522913236-15776-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20180405075753.GZ6312@dhcp22.suse.cz>
 <20180405080539.GA631@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405080539.GA631@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 05-04-18 17:05:39, Joonsoo Kim wrote:
> On Thu, Apr 05, 2018 at 09:57:53AM +0200, Michal Hocko wrote:
> > On Thu 05-04-18 16:27:16, Joonsoo Kim wrote:
> > > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > 
> > > ZONE_MOVABLE only has movable pages so we don't need to keep enough
> > > freepages to avoid or deal with fragmentation. So, don't count it.
> > > 
> > > This changes min_free_kbytes and thus min_watermark greatly
> > > if ZONE_MOVABLE is used. It will make the user uses more memory.
> > 
> > OK, but why does it matter. Has anybody seen this as an issue?
> 
> There was a regression report for CMA patchset and I think that it is
> related to this problem. CMA patchset makes the system uses one more
> zone (ZONE_MOVABLE) and then increase min_free_kbytes. It reduces
> usable memory and it could cause regression.
> 
> http://lkml.kernel.org/r/20180102063528.GG30397@yexl-desktop

Then this should be a part of the changelog along with some reproducible
results, please.
-- 
Michal Hocko
SUSE Labs
