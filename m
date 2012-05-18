Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id E35A56B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 09:57:42 -0400 (EDT)
Date: Fri, 18 May 2012 08:57:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 3/9] Extract common fields from struct
 kmem_cache
In-Reply-To: <alpine.LFD.2.02.1205181221570.3899@tux.localdomain>
Message-ID: <alpine.DEB.2.00.1205180855450.21093@router.home>
References: <20120514201544.334122849@linux.com> <20120514201610.559075441@linux.com> <alpine.LFD.2.02.1205160943180.2249@tux.localdomain> <alpine.DEB.2.00.1205160922520.25512@router.home> <alpine.LFD.2.02.1205181221570.3899@tux.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Fri, 18 May 2012, Pekka Enberg wrote:

> Why not make a "struct kmem_cache_common" structure and use that? You can
> embed it in "struct kmem_cache" just fine.

Tried that but I ended up with having to qualify all common variables.

I.e.

struct kmem_cache {
	struct kmem_cache_common {
		int a,b
	} common
} kmem_cache;


requires

	kmemcache->common.a

instead of

	kmemcache->a

That in turn requires significant changes to all allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
