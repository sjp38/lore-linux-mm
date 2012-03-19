Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id A23696B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:28:59 -0400 (EDT)
Date: Mon, 19 Mar 2012 10:28:56 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: object allocation benchmark
In-Reply-To: <4F6743C2.3090906@parallels.com>
Message-ID: <alpine.DEB.2.00.1203191028160.19189@router.home>
References: <4F6743C2.3090906@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 19 Mar 2012, Glauber Costa wrote:

> I was wondering: Which benchmark would be considered the canonical one to
> demonstrate the speed of the slub/slab after changes? In particular, I have
> the kmem-memcg in mind

I have some in kernel benchmarking tools for page allocator and slab
allocators. But they are not really clean patches.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
