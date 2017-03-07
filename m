Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D92C36B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 06:29:57 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id h188so486628wma.4
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 03:29:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o67si18452207wme.150.2017.03.07.03.29.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 03:29:56 -0800 (PST)
Date: Tue, 7 Mar 2017 12:29:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH 1/2] mm: use MIGRATE_HIGHATOMIC as late as possible
Message-ID: <20170307112953.GF28642@dhcp22.suse.cz>
References: <58BE8C91.20600@huawei.com>
 <20170307104758.GE28642@dhcp22.suse.cz>
 <58BE938B.9020908@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58BE938B.9020908@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 07-03-17 19:03:39, Xishi Qiu wrote:
> On 2017/3/7 18:47, Michal Hocko wrote:
> 
> > On Tue 07-03-17 18:33:53, Xishi Qiu wrote:
> >> MIGRATE_HIGHATOMIC page blocks are reserved for an atomic
> >> high-order allocation, so use it as late as possible.
> > 
> > Why is this better? Are you seeing any problem which this patch
> > resolves? In other words the patch description should explain why not
> > only what (that is usually clear from looking at the diff).
> > 
> 
> Hi Michal,
> 
> I have not see any problem yet, I think if we reserve more high order
> pageblocks, the more success rate we will get when meet an atomic
> high-order allocation, right?

Please make sure you measure your changes under different workloads and
present numbers in the changelog when you are touch such a subtle things
like memory reserves. Ideas that might sound they make sense can turn
out to behave differently in the real life.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
