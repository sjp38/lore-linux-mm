Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 069D26B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 09:16:44 -0400 (EDT)
Received: by wiun10 with SMTP id n10so21984053wiu.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 06:16:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p4si2210920wiy.6.2015.05.06.06.16.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 06:16:42 -0700 (PDT)
Date: Wed, 6 May 2015 09:16:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] gfp: add __GFP_NOACCOUNT
Message-ID: <20150506131622.GA4629@cmpxchg.org>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
 <20150506115941.GH14550@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150506115941.GH14550@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 06, 2015 at 01:59:41PM +0200, Michal Hocko wrote:
> On Tue 05-05-15 12:45:42, Vladimir Davydov wrote:
> > Not all kmem allocations should be accounted to memcg. The following
> > patch gives an example when accounting of a certain type of allocations
> > to memcg can effectively result in a memory leak.
> 
> > This patch adds the __GFP_NOACCOUNT flag which if passed to kmalloc
> > and friends will force the allocation to go through the root
> > cgroup. It will be used by the next patch.
> 
> The name of the flag is way too generic. It is not clear that the
> accounting is KMEMCG related.

The memory controller is the (primary) component that accounts
physical memory allocations in the kernel, so I don't see how this
would be ambiguous in any way.

> __GFP_NO_KMEMCG sounds better?

I think that's much worse.  I would prefer communicating the desired
behavior directly instead of having to derive it from a subsystem
name.

(And KMEMCG should not even be a term, it's all just the memory
controller, i.e. memcg.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
