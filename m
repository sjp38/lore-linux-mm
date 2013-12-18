Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id C6BA36B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 08:47:54 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so3511974eek.15
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 05:47:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m44si13653eeo.247.2013.12.18.05.47.52
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 05:47:53 -0800 (PST)
Message-ID: <52B1A781.50002@redhat.com>
Date: Wed, 18 Dec 2013 08:47:45 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v3
References: <1387298904-8824-1-git-send-email-mgorman@suse.de> <20131217200210.GG21724@cmpxchg.org> <20131218061750.GK21724@cmpxchg.org>
In-Reply-To: <20131218061750.GK21724@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/18/2013 01:17 AM, Johannes Weiner wrote:

> Updated version with your tmpfs __GFP_PAGECACHE parts added and
> documentation, changelog updated as necessary.  I remain unconvinced
> that tmpfs pages should be round-robined, but I agree with you that it
> is the conservative change to do for 3.12 and 3.12 and we can figure
> out the rest later.  I sure hope that this doesn't drive most people
> on NUMA to disable pagecache interleaving right away as I expect most
> tmpfs workloads to see little to no reclaim and prefer locality... :/

Actually, I suspect most tmpfs heavy workloads will be things like
databases with shared memory segments. Those tend to benefit from
having all of the system's memory bandwidth available. The worker
threads/processes tend to live all over the system, too...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
