Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 4694F6B005A
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:17:14 -0400 (EDT)
Message-ID: <501A8BE4.4060206@parallels.com>
Date: Thu, 2 Aug 2012 18:17:08 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [00/16] Sl[auo]b: Common code rework V8
References: <20120801211130.025389154@linux.com> <501A3F1E.4060307@parallels.com> <alpine.DEB.2.00.1208020912340.23049@router.home>
In-Reply-To: <alpine.DEB.2.00.1208020912340.23049@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 06:13 PM, Christoph Lameter wrote:
> On Thu, 2 Aug 2012, Glauber Costa wrote:
> 
>> After applying v8, and proceeding with cache deletion + later insertion
>> as I've previously laid down, I can still see the bug I mentioned here.
>>
>> I am attaching the backtrace I've got with SLUB_DEBUG_ON. My first guess
>> based on it would be a double free somewhere.
> 
> This looks like you are passing an invalid pointer to kfree.
> 

Which is then the patchset's fault. Since as I said, my call order is:

kmem_cache_create() -> kmem_cache_destroy().

All allocs and frees are implicit.

It also works okay both before the patches are applied, and with slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
