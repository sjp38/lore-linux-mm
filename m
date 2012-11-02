Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 45F8C6B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 19:06:44 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3017672pbb.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 16:06:43 -0700 (PDT)
Date: Fri, 2 Nov 2012 16:06:38 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v6 00/29] kmem controller for memcg.
Message-ID: <20121102230638.GE27843@mtj.dyndns.org>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
 <20121101170454.b7713bce.akpm@linux-foundation.org>
 <50937918.7080302@parallels.com>
 <CAAmzW4O74e3J9M3Q86Y0wXX6Pfp8GDpv6jAB5ebJPHfAxAeL0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4O74e3J9M3Q86Y0wXX6Pfp8GDpv6jAB5ebJPHfAxAeL0Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>

Hey, Joonsoo.

On Sat, Nov 03, 2012 at 04:25:59AM +0900, JoonSoo Kim wrote:
> I am worrying about data cache footprint which is possibly caused by
> this patchset, especially slab implementation.
> If there are several memcg cgroups, each cgroup has it's own kmem_caches.
> When each group do slab-intensive job hard, data cache may be overflowed easily,
> and cache miss rate will be high, therefore this would decrease system
> performance highly.

It would be nice to be able to remove such overhead too, but the
baselines for cgroup implementations (well, at least the ones that I
think important) in somewhat decreasing priority are...

1. Don't over-complicate the target subsystem.

2. Overhead when cgroup is not used should be minimal.  Prefereably to
   the level of being unnoticeable.

3. Overhead while cgroup is being actively used should be reasonable.

If you wanna split your system into N groups and maintain memory
resource segregation among them, I don't think it's unreasonable to
ask for paying data cache footprint overhead.

So, while improvements would be nice, I wouldn't consider overheads of
this type as a blocker.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
