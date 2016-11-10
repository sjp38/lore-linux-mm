Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 58BAC6B027A
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:07:24 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so5391523wma.2
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 01:07:24 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id yn1si3994106wjc.162.2016.11.10.01.07.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 01:07:23 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id CC1499922D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:07:22 +0000 (UTC)
Date: Thu, 10 Nov 2016 09:07:22 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC] mem-hotplug: shall we skip unmovable node when doing numa
 balance?
Message-ID: <20161110090722.yyznotwqqxz3v6uo@techsingularity.net>
References: <582157E5.8000106@huawei.com>
 <20161109115827.GD3614@techsingularity.net>
 <5823E6AF.8040600@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5823E6AF.8040600@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "robert.liu@huawei.com" <robert.liu@huawei.com>

On Thu, Nov 10, 2016 at 11:17:03AM +0800, Xishi Qiu wrote:
> On 2016/11/9 19:58, Mel Gorman wrote:
> 
> > On Tue, Nov 08, 2016 at 12:43:17PM +0800, Xishi Qiu wrote:
> >> On mem-hotplug system, there is a problem, please see the following case.
> >>
> >> memtester xxG, the memory will be alloced on a movable node. And after numa
> >> balancing, the memory may be migrated to the other node, it may be a unmovable
> >> node. This will reduce the free memory of the unmovable node, and may be oom
> >> later.
> >>
> > 
> > How would it OOM later? It's movable memmory that is moving via
> > automatic NUMA balancing so at the very least it can be reclaimed. If
> > the memory is mlocked or unable to migrate then it's irrelevant if
> > automatic balancing put it there.
> > 
> 
> memtester will mlock the memory, so we can not reclaim, then maybe oom, right?
> So let the manager set some numa policies to prevent the above case, right?
> 

Deal with it using policies.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
