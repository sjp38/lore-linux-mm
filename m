Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDA76B002B
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:30:07 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id v9-v6so4446052lfe.19
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:30:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a18-v6sor3374738lfi.111.2018.04.24.05.30.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 05:30:05 -0700 (PDT)
Date: Tue, 24 Apr 2018 15:30:02 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2] mm: introduce memory.min
Message-ID: <20180424123002.utwbm54mu46q6aqs@esperanza>
References: <20180423123610.27988-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423123610.27988-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>

Hi Roman,

On Mon, Apr 23, 2018 at 01:36:10PM +0100, Roman Gushchin wrote:
> +  memory.min
> +	A read-write single value file which exists on non-root
> +	cgroups.  The default is "0".
> +
> +	Hard memory protection.  If the memory usage of a cgroup
> +	is within its effective min boundary, the cgroup's memory
> +	won't be reclaimed under any conditions. If there is no
> +	unprotected reclaimable memory available, OOM killer
> +	is invoked.

What will happen if all tasks attached to a cgroup are killed by OOM,
but its memory usage is still within memory.min? Will memory.min be
ignored then?

> +
> +	Effective low boundary is limited by memory.min values of
> +	all ancestor cgroups. If there is memory.min overcommitment
> +	(child cgroup or cgroups are requiring more protected memory
> +	than parent will allow), then each child cgroup will get
> +	the part of parent's protection proportional to its
> +	actual memory usage below memory.min.
> +
> +	Putting more memory than generally available under this
> +	protection is discouraged and may lead to constant OOMs.
