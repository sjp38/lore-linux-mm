Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id D91A06B006C
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:53:19 -0500 (EST)
Received: by qcvs11 with SMTP id s11so16506894qcv.11
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:53:19 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id v8si5389625qas.121.2015.02.27.14.53.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 14:53:18 -0800 (PST)
Date: Fri, 27 Feb 2015 16:53:16 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
In-Reply-To: <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1502271649060.20876@gentwo.org>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, dev@openvswitch.org

On Fri, 27 Feb 2015, David Rientjes wrote:

> +/*
> + * Construct gfp mask to allocate from a specific node but do not invoke reclaim
> + * or warn about failures.
> + */

We should be triggering reclaim from slab allocations. Why would we not do
this?

Otherwise we will be going uselessly off node for slab allocations.

> +static inline gfp_t gfp_exact_node(gfp_t flags)
> +{
> +	return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_WAIT;
> +}
>  #endif

Reclaim needs to be triggered. In particular zone reclaim was made to be
triggered from slab allocations to create more room if needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
