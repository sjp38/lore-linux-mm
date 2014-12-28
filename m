Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E62F96B006E
	for <linux-mm@kvack.org>; Sun, 28 Dec 2014 14:00:29 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so17451839wgh.22
        for <linux-mm@kvack.org>; Sun, 28 Dec 2014 11:00:29 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id la7si68030769wjc.139.2014.12.28.11.00.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Dec 2014 11:00:29 -0800 (PST)
Date: Sun, 28 Dec 2014 14:00:20 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 1/2] memcg: account swap instead of memory+swap
Message-ID: <20141228190020.GA9385@phnom.home.cmpxchg.org>
References: <dd99dc0de2ce6fd9aa18b25851819b71a58dca7d.1419782051.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dd99dc0de2ce6fd9aa18b25851819b71a58dca7d.1419782051.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sun, Dec 28, 2014 at 07:19:12PM +0300, Vladimir Davydov wrote:
> The design of swap limits for memory cgroups looks broken. Instead of a
> separate swap limit, there is the memory.memsw.limit_in_bytes knob,
> which limits total memory+swap consumption. As a result, under global
> memory pressure, a cgroup can eat up to memsw.limit of *swap*, so it's
> just impossible to set the swap limit to be less than the memory limit
> with such a design. In particular, this means that we have to leave swap
> unlimited if we want to partition system memory dynamically using soft
> limits.
> 
> This patch therefore attempts to move from memory+swap to pure swap
> accounting so that we will be able to separate memory and swap resources
> in the sane cgroup hierarchy, which is the business of the following
> patch.
> 
> The old interface acts on memory and swap limits as follows:

The implementation seems fine to me, but there is no point in cramming
this into the old interface.  Let's just leave it alone and implement
proper swap accounting and limiting in the default/unified hierarchy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
