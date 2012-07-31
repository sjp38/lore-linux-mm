Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp102.postini.com [74.125.245.222])
	by kanga.kvack.org (Postfix) with SMTP id 8C5EE6B00A1
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:26:10 -0400 (EDT)
Message-ID: <50180AC0.1040403@parallels.com>
Date: Tue, 31 Jul 2012 20:41:36 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [13/20] Extract a common function for kmem_cache_destroy
References: <20120601195245.084749371@linux.com> <20120601195307.063633659@linux.com> <5017C90E.7060706@parallels.com> <alpine.DEB.2.00.1207310910580.32295@router.home> <5017E8C3.1040004@parallels.com> <alpine.DEB.2.00.1207310942090.32295@router.home> <5017EFE9.1080804@parallels.com> <alpine.DEB.2.00.1207311129520.32295@router.home>
In-Reply-To: <alpine.DEB.2.00.1207311129520.32295@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 07/31/2012 08:30 PM, Christoph Lameter wrote:
> On Tue, 31 Jul 2012, Glauber Costa wrote:
> 
>> Yes, but since deleting caches is not a common operation in the kernel,
>> you will have to force somehow.
> 
> On bootup the ACPI subsystem creates some caches and also removes them.
> This bug actually triggers here even when using kvm. Seems that this is
> due to some use of kmalloc allocations for kmem_cache in slub where we use
> kmalloc-256 instead of kmem_cache.
> 
Ok, maybe this is due to a difference in our setup. I needed to
explicitly create and destroy caches to trigger it.

But as long as it is fixed, it doesn't really matter =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
