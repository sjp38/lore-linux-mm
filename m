Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 29368600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 17:58:02 -0500 (EST)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id nAUMvwDX017841
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 22:57:58 GMT
Received: from pzk7 (pzk7.prod.google.com [10.243.19.135])
	by spaceape23.eur.corp.google.com with ESMTP id nAUMrv5t016802
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 14:57:56 -0800
Received: by pzk7 with SMTP id 7so6586773pzk.30
        for <linux-mm@kvack.org>; Mon, 30 Nov 2009 14:57:55 -0800 (PST)
Date: Mon, 30 Nov 2009 14:57:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: memcg: slab control
In-Reply-To: <4B0E7530.8050304@parallels.com>
Message-ID: <alpine.DEB.2.00.0911301457110.7131@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>  <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>  <20091126085031.GG2970@balbir.in.ibm.com>  <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>  <4B0E461C.50606@parallels.com>
  <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>  <4B0E50B1.20602@parallels.com> <d26f1ae00911260224k6b87aaf7o9e3a983a73e6036e@mail.gmail.com> <4B0E7530.8050304@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Nov 2009, Pavel Emelyanov wrote:

> I disagree. Bio-s are allocated in user context for all typical reads
> (unless we requested aio) and are allocated either in pdflush context
> or (!) in arbitrary task context for writes (e.g. via try_to_free_pages)
> and thus such bio/buffer_head accounting will be completely random.
> 

pdflush has been removed, they should all be allocated in process context.

> We implement support for accounting based on a bit on a kmem_cache
> structure and mark all kmalloc caches as not-accountable. Then we grep
> the kernel to find all kmalloc-s and think - if a kmalloc is to be
> accounted we turn this into kmem_cache_alloc() with dedicated
> kmem_cache and mark it as accountable.
> 

That doesn't work with slab cache merging done in slub.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
