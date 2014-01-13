Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 988DF6B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 18:11:35 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so7870835pbc.26
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 15:11:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id eb3si16964661pbd.287.2014.01.13.15.11.33
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 15:11:34 -0800 (PST)
Date: Mon, 13 Jan 2014 15:11:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/5] mm: vmscan: respect NUMA policy mask when shrinking
 slab on direct reclaim
Message-Id: <20140113151132.d07cbc938baf5af70f929120@linux-foundation.org>
In-Reply-To: <a39e4c57c5a8db4d6e5bb8cd070ac807c8c6fce8.1389443272.git.vdavydov@parallels.com>
References: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com>
	<a39e4c57c5a8db4d6e5bb8cd070ac807c8c6fce8.1389443272.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

On Sat, 11 Jan 2014 16:36:33 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:

> When direct reclaim is executed by a process bound to a set of NUMA
> nodes, we should scan only those nodes when possible, but currently we
> will scan kmem from all online nodes even if the kmem shrinker is NUMA
> aware. That said, binding a process to a particular NUMA node won't
> prevent it from shrinking inode/dentry caches from other nodes, which is
> not good. Fix this.

Seems right.  I worry that reducing the amount of shrinking which
node-bound processes perform might affect workloads in unexpected ways.

I think I'll save this one for 3.15-rc1, OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
