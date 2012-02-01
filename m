Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id E30B76B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 17:11:59 -0500 (EST)
Received: by pbaa12 with SMTP id a12so1820192pba.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 14:11:59 -0800 (PST)
Date: Wed, 1 Feb 2012 14:11:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup 6/9] slub: Get rid of the node field
In-Reply-To: <20120123201708.869898930@linux.com>
Message-ID: <alpine.DEB.2.00.1202011411250.10854@chino.kir.corp.google.com>
References: <20120123201646.924319545@linux.com> <20120123201708.869898930@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

On Mon, 23 Jan 2012, Christoph Lameter wrote:

> The node field is always page_to_nid(c->page). So its rather easy to
> replace. Note that there maybe slightly more overhead in various hot paths
> due to the need to shift the bits from page->flags. However, that is mostly
> compensated for by a smaller footprint of the kmem_cache_cpu structure (this
> patch reduces that to 3 words per cache) which allows better caching.
> 

s/3 words per cache/4 words per cache/

> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
