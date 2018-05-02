Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 618656B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 08:28:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d82so4484310wmd.4
        for <linux-mm@kvack.org>; Wed, 02 May 2018 05:28:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p91-v6si253776edp.99.2018.05.02.05.28.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 May 2018 05:28:55 -0700 (PDT)
Date: Wed, 2 May 2018 08:30:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: introduce memory.min
Message-ID: <20180502123040.GA16060@cmpxchg.org>
References: <20180423123610.27988-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423123610.27988-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 23, 2018 at 01:36:10PM +0100, Roman Gushchin wrote:
> @@ -59,6 +59,12 @@ enum memcg_memory_event {
>  	MEMCG_NR_MEMORY_EVENTS,
>  };
>  
> +enum mem_cgroup_protection {
> +	MEMCG_PROT_NONE,
> +	MEMCG_PROT_LOW,
> +	MEMCG_PROT_HIGH,

Ha, HIGH doesn't make much sense, but I went back and it's indeed what
I suggested. Must have been a brainfart. This should be

MEMCG_PROT_NONE,
MEMCG_PROT_LOW,
MEMCG_PROT_MIN

right? To indicate which type of protection is applying.

The rest of the patch looks good:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
