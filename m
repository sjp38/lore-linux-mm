Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id E84616B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 10:49:59 -0400 (EDT)
Message-ID: <5017EFE9.1080804@parallels.com>
Date: Tue, 31 Jul 2012 18:47:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [13/20] Extract a common function for kmem_cache_destroy
References: <20120601195245.084749371@linux.com> <20120601195307.063633659@linux.com> <5017C90E.7060706@parallels.com> <alpine.DEB.2.00.1207310910580.32295@router.home> <5017E8C3.1040004@parallels.com> <alpine.DEB.2.00.1207310942090.32295@router.home>
In-Reply-To: <alpine.DEB.2.00.1207310942090.32295@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 07/31/2012 06:42 PM, Christoph Lameter wrote:
> On Tue, 31 Jul 2012, Glauber Costa wrote:
> 
>> Since you said you had reworked this, I'll just stop looking for now.
>> But would you please make sure that this following use case is well
>> tested before you send?
>>
>> 1) After machine is up, create a bogus cache
>> 2) free that cache right away.
>> 3) Create two more caches.
>>
>> The creation of the second cache fails, because
>> kmem_cache_alloc(kmem_cache, x) returns bad values. Those bad values can
>> take multiple forms, but the most common is a value that is equal to an
>> already assigned value.
> 
> If you enable debugging you will see those issues right away and do not
> need to infer from other problems that there is an issue in the
> allocators.
> 
Yes, but since deleting caches is not a common operation in the kernel,
you will have to force somehow.

I didn't see anything with debugging enabled, simply because there is no
problem at all before you remove the first cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
