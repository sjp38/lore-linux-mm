Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 474376B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 16:24:50 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so19300162wjy.6
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 13:24:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t15si6706556wra.71.2017.01.17.13.24.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 13:24:49 -0800 (PST)
Subject: Re: [PATCH 1/4] mm, page_alloc: Split buffered_rmqueue
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-2-mgorman@techsingularity.net>
 <20170117190732.0fc733ec@redhat.com>
 <2df88f73-a32d-4b71-d4de-3a0ad8831d9a@suse.cz>
 <20170117202008.pcufk5qencdgkgpj@techsingularity.net>
 <20170117210749.rzpsavbx5gztsx6o@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <39207e24-a937-e4d8-4b2e-a06b68ea9855@suse.cz>
Date: Tue, 17 Jan 2017 22:24:28 +0100
MIME-Version: 1.0
In-Reply-To: <20170117210749.rzpsavbx5gztsx6o@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>

On 01/17/2017 10:07 PM, Mel Gorman wrote:
> On Tue, Jan 17, 2017 at 08:20:08PM +0000, Mel Gorman wrote:
> 
> I later recalled that we looked at this before and didn't think a reinit
> was necessary because the location of cpuset_current_mems_allowed doesn't
> change so I came back and took another look.  The location doesn't change
> but after the first attempt, we reset ac.nodemask to the given nodemask and
> don't recheck current_mems_allowed if the cpuset changed. The application
> of memory policies versus cpusets is a mess so it'll take time to pick
> apart to see if this is even remotely in the right direction.

Yes, I spent most of last 2 days untangling this, so I'll post at least
some RFC soon.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
