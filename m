Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 3E9B66B0105
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:32:07 -0400 (EDT)
Message-ID: <4FE39290.8020609@redhat.com>
Date: Thu, 21 Jun 2012 17:30:56 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/17] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
References: <1340192652-31658-1-git-send-email-mgorman@suse.de> <1340192652-31658-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1340192652-31658-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>

On 06/20/2012 07:43 AM, Mel Gorman wrote:

> +/* Clears ac->pfmemalloc if no slabs have pfmalloc set */
> +static void check_ac_pfmemalloc(struct kmem_cache *cachep,
> +						struct array_cache *ac)
> +{

> +	pfmemalloc_active = false;
> +out:
> +	spin_unlock_irqrestore(&l3->list_lock, flags);
> +}

The comment and the function do not seem to match.

Otherwise, the patch looks reasonable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
