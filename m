Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3DC600786
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 05:31:27 -0500 (EST)
Message-ID: <4B14F06D.1000901@parallels.com>
Date: Tue, 01 Dec 2009 13:31:09 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg: slab control
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>  <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>  <20091126085031.GG2970@balbir.in.ibm.com>  <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>  <4B0E461C.50606@parallels.com>  <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>  <4B0E50B1.20602@parallels.com> <d26f1ae00911260224k6b87aaf7o9e3a983a73e6036e@mail.gmail.com> <4B0E7530.8050304@parallels.com> <alpine.DEB.2.00.0911301457110.7131@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0911301457110.7131@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Thu, 26 Nov 2009, Pavel Emelyanov wrote:
> 
>> I disagree. Bio-s are allocated in user context for all typical reads
>> (unless we requested aio) and are allocated either in pdflush context
>> or (!) in arbitrary task context for writes (e.g. via try_to_free_pages)
>> and thus such bio/buffer_head accounting will be completely random.
>>
> 
> pdflush has been removed, they should all be allocated in process context.

OK, but the try_to_free_pages() concern still stands.

>> We implement support for accounting based on a bit on a kmem_cache
>> structure and mark all kmalloc caches as not-accountable. Then we grep
>> the kernel to find all kmalloc-s and think - if a kmalloc is to be
>> accounted we turn this into kmem_cache_alloc() with dedicated
>> kmem_cache and mark it as accountable.
>>
> 
> That doesn't work with slab cache merging done in slub.

Surely we'll have to change it a bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
