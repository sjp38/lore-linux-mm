Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 4AC926B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 18:04:15 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so5608330pbc.0
        for <linux-mm@kvack.org>; Thu, 27 Dec 2012 15:04:14 -0800 (PST)
Date: Thu, 27 Dec 2012 15:04:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm, bootmem: panic in bootmem alloc functions even
 if slab is available
In-Reply-To: <50DCCE5A.4000805@oracle.com>
Message-ID: <alpine.DEB.2.00.1212271502070.23127@chino.kir.corp.google.com>
References: <1356293711-23864-1-git-send-email-sasha.levin@oracle.com> <1356293711-23864-2-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.00.1212271423210.18214@chino.kir.corp.google.com> <50DCCE5A.4000805@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 27 Dec 2012, Sasha Levin wrote:

> That's exactly what happens with the patch. Note that in the current upstream
> version there are several slab checks scattered all over.
> 
> In this case for example, I'm removing it from __alloc_bootmem_node(), but the
> first code line of__alloc_bootmem_node_nopanic() is:
> 
>         if (WARN_ON_ONCE(slab_is_available()))
>                 return kzalloc(size, GFP_NOWAIT);
> 

You're only talking about mm/bootmem.c and not mm/nobootmem.c, and notice 
that __alloc_bootmem_node() does not call __alloc_bootmem_node_nopanic(), 
it calls ___alloc_bootmem_node_nopanic().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
