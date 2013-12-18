Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id 187446B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 09:18:07 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so221823bkz.15
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 06:18:07 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id tq3si235796bkb.139.2013.12.18.06.18.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 06:18:06 -0800 (PST)
Date: Wed, 18 Dec 2013 09:17:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v3
Message-ID: <20131218141758.GL21724@cmpxchg.org>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
 <20131217200210.GG21724@cmpxchg.org>
 <20131218061750.GK21724@cmpxchg.org>
 <52B1A781.50002@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B1A781.50002@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 08:47:45AM -0500, Rik van Riel wrote:
> On 12/18/2013 01:17 AM, Johannes Weiner wrote:
> 
> > Updated version with your tmpfs __GFP_PAGECACHE parts added and
> > documentation, changelog updated as necessary.  I remain unconvinced
> > that tmpfs pages should be round-robined, but I agree with you that it
> > is the conservative change to do for 3.12 and 3.12 and we can figure
> > out the rest later.  I sure hope that this doesn't drive most people
> > on NUMA to disable pagecache interleaving right away as I expect most
> > tmpfs workloads to see little to no reclaim and prefer locality... :/
> 
> Actually, I suspect most tmpfs heavy workloads will be things like
> databases with shared memory segments. Those tend to benefit from
> having all of the system's memory bandwidth available. The worker
> threads/processes tend to live all over the system, too...

Shared memory segments are explicitely excluded from the interleaving,
though.  The distinction is between the internal tmpfs mount that sysv
shmem uses (mempolicy) and tmpfs mounts that use the actual filesystem
interface (pagecache interleave).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
