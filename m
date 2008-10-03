Message-ID: <48E642CA.2050405@linux-foundation.org>
Date: Fri, 03 Oct 2008 11:05:30 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch 2/3] cpu alloc: Use in slub
References: <20081003152436.089811999@quilx.com> <20081003152500.102106878@quilx.com> <48E63E76.1010702@cosmosbay.com>
In-Reply-To: <48E63E76.1010702@cosmosbay.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Eric Dumazet wrote:
>
> Then maybe change MAX_NUMNODES to 0 or 1 to reflect
> node[] is dynamically sized ?

See kmem_cache_init(). It only allocates the used bytes. If you only have a
single nodes then only 1 pointer will be allocated.

#ifdef CONFIG_NUMA
        kmem_size = offsetof(struct kmem_cache, node) +
                                nr_node_ids * sizeof(struct kmem_cache_node *);
#else


That does not work for the statically allocated kmalloc array though.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
