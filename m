Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 02C1B6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 19:56:46 -0500 (EST)
Received: by iebtr6 with SMTP id tr6so9940329ieb.10
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:56:45 -0800 (PST)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id n2si221624ico.51.2015.02.25.16.56.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 16:56:45 -0800 (PST)
Date: Wed, 25 Feb 2015 18:56:43 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
In-Reply-To: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1502251855330.14795@gentwo.org>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org

On Wed, 25 Feb 2015, David Rientjes wrote:

> NOTE: this is not about __GFP_THISNODE, this is only about GFP_THISNODE.

Well but then its not removing it. You are replacing it with an inline
function.

> +
> +/*
> + * Construct gfp mask to allocate from a specific node but do not invoke reclaim
> + * or warn about failures.
> + */
> +static inline gfp_t gfp_exact_node(gfp_t flags)
> +{
> +	return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_WAIT;
> +}
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
