Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD4D6B0006
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:01:25 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id a193-v6so1981410ioa.23
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:01:25 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j75-v6si5630116ioe.60.2018.04.20.10.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 10:01:24 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: introduce memory.min
References: <20180420163632.3978-1-guro@fb.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <527af98a-8d7f-42ab-9ba8-71444ef7e25f@infradead.org>
Date: Fri, 20 Apr 2018 10:01:04 -0700
MIME-Version: 1.0
In-Reply-To: <20180420163632.3978-1-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On 04/20/18 09:36, Roman Gushchin wrote:

> ---
>  Documentation/cgroup-v2.txt  | 20 +++++++++
>  include/linux/memcontrol.h   | 15 ++++++-
>  include/linux/page_counter.h | 11 ++++-
>  mm/memcontrol.c              | 99 ++++++++++++++++++++++++++++++++++++--------
>  mm/page_counter.c            | 63 ++++++++++++++++++++--------
>  mm/vmscan.c                  | 19 ++++++++-
>  6 files changed, 189 insertions(+), 38 deletions(-)
> 
> diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> index 657fe1769c75..49c846020f96 100644
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -1002,6 +1002,26 @@ PAGE_SIZE multiple when read back.
>  	The total amount of memory currently being used by the cgroup
>  	and its descendants.
>  
> +  memory.min
> +	A read-write single value file which exists on non-root
> +	cgroups.  The default is "0".
> +
> +	Hard memory protection.  If the memory usage of a cgroup
> +	is within its effectife min boundary, the cgroup's memory

	              effective

> +	won't be reclaimed under any conditions. If there is no
> +	unprotected reclaimable memory available, OOM killer
> +	is invoked.
> +
> +	Effective low boundary is limited by memory.min values of
> +	all ancestor cgroups. If there is memory.mn overcommitment

	                                  memory.min ? overcommit

> +	(child cgroup or cgroups are requiring more protected memory,

	                                          drop ending ','  ^^

> +	than parent will allow), then each child cgroup will get
> +	the part of parent's protection proportional to the its

	                                             to its

> +	actual memory usage below memory.min.
> +
> +	Putting more memory than generally available under this
> +	protection is discouraged and may lead to constant OOMs.
> +
>    memory.low
>  	A read-write single value file which exists on non-root
>  	cgroups.  The default is "0".


-- 
~Randy
