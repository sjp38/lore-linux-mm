Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id CAFA86B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 08:55:20 -0500 (EST)
Date: Wed, 22 Feb 2012 07:55:16 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
In-Reply-To: <20120222115320.GA3107@x61.redhat.com>
Message-ID: <alpine.DEB.2.00.1202220754140.21637@router.home>
References: <20120222115320.GA3107@x61.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Wed, 22 Feb 2012, Rafael Aquini wrote:

> --- a/mm/slub.c
> +++ b/mm/slub.c
> +void oom_dump_slabs(int ratio)
> +{

> +
> +		for_each_online_node(node) {
> +			struct kmem_cache_node *n = get_node(cachep, node);
> +			if (!n)
> +				continue;
> +
> +			nr_objs += atomic_long_read(&n->total_objects);

Please use node_nr_objects() instead of directly accessing total_objects.
total_objects are only available if debugging support was compiled in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
