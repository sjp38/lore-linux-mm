Message-ID: <48E4F4EE.90608@linux-foundation.org>
Date: Thu, 02 Oct 2008 11:21:02 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch 2/3] cpu alloc: Remove slub fields
References: <20080919203703.312007962@quilx.com> <20080919203724.240858174@quilx.com> <48E3B904.7020206@cs.helsinki.fi>
In-Reply-To: <48E3B904.7020206@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Hi Christoph,
> 
> Christoph Lameter wrote:
>> @@ -2196,8 +2163,11 @@
>>      if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
>>          goto error;
>>  
>> -    if (alloc_kmem_cache_cpus(s, gfpflags & ~SLUB_DMA))
>> +    s->cpu_slab = CPU_ALLOC(struct kmem_cache_cpu,
>> +                (flags & ~SLUB_DMA) | __GFP_ZERO);
>> +    if (!s->cpu_slab)
>>          return 1;
> 
> This should be s->cpu_slab, no?

Correct. Newer rev that will be based on cpu_alloc V6 will have that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
