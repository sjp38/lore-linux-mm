Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5CB16B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 09:00:52 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id o12so31354671lfg.7
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 06:00:52 -0800 (PST)
Received: from smtp23.mail.ru (smtp23.mail.ru. [94.100.181.178])
        by mx.google.com with ESMTPS id l136si2724604lfg.4.2017.01.14.06.00.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 06:00:51 -0800 (PST)
Date: Sat, 14 Jan 2017 17:00:43 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 9/9] slab: remove slub sysfs interface files early for
 empty memcg caches
Message-ID: <20170114140043.GH2668@esperanza>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-10-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114055449.11044-10-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 12:54:49AM -0500, Tejun Heo wrote:
> With kmem cgroup support enabled, kmem_caches can be created and
> destroyed frequently and a great number of near empty kmem_caches can
> accumulate if there are a lot of transient cgroups and the system is
> not under memory pressure.  When memory reclaim starts under such
> conditions, it can lead to consecutive deactivation and destruction of
> many kmem_caches, easily hundreds of thousands on moderately large
> systems, exposing scalability issues in the current slab management
> code.  This is one of the patches to address the issue.
> 
> Each cache has a number of sysfs interface files under
> /sys/kernel/slab.  On a system with a lot of memory and transient
> memcgs, the number of interface files which have to be removed once
> memory reclaim kicks in can reach millions.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Jay Vana <jsvana@fb.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
