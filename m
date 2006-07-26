Message-ID: <44C7AF31.9000507@colorfullife.com>
Date: Wed, 26 Jul 2006 20:06:41 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2] slab: always consider arch mandated alignment
References: <Pine.LNX.4.64.0607220748160.13737@schroedinger.engr.sgi.com> <20060722162607.GA10550@osiris.ibm.com> <Pine.LNX.4.64.0607221241130.14513@schroedinger.engr.sgi.com> <20060723073500.GA10556@osiris.ibm.com> <Pine.LNX.4.64.0607230558560.15651@schroedinger.engr.sgi.com> <20060723162427.GA10553@osiris.ibm.com> <20060726085113.GD9592@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.58.0607261303270.17613@sbz-30.cs.Helsinki.FI> <20060726101340.GE9592@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.58.0607261325070.17986@sbz-30.cs.Helsinki.FI> <20060726105204.GF9592@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.58.0607261411420.17986@sbz-30.cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.58.0607261411420.17986@sbz-30.cs.Helsinki.FI>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.Helsinki.FI>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Pekka J Enberg wrote:

>On Wed, 26 Jul 2006, Heiko Carstens wrote:
>  
>
>>We only specify ARCH_KMALLOC_MINALIGN, since that aligns only the kmalloc
>>caches, but it doesn't disable debugging on other caches that are created
>>via kmem_cache_create() where an alignment of e.g. 0 is specified.
>>
>>The point of the first patch is: why should the slab cache be allowed to chose
>>an aligment that is less than what the caller specified? This does very likely
>>break things.
>>    
>>
>
>Ah, yes, you are absolutely right. We need to respect caller mandated 
>alignment too. How about this?
>
>  
>
Good catch - I obviously never tested the code for an HWCACHE_ALIGN cache...


>			Pekka
>
>[PATCH] slab: respect architecture and caller mandated alignment
>
>Ensure cache alignment is always at minimum what the architecture or 
>caller mandates even if slab debugging is enabled.
>
>Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
>  
>
Signed-off-by: Manfred Spraul <manfred@colorfullife.com>

--
    Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
