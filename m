Date: Sun, 06 May 2007 21:19:19 +0200
From: Bert Wesarg <wesarg@informatik.uni-halle.de>
Subject: Re: [RFC 1/3] SLUB: slab_ops instead of constructors / destructors
In-reply-to: <20070504221708.363027097@sgi.com>
Message-id: <463E2A37.2030400@informatik.uni-halle.de>
MIME-version: 1.0
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7BIT
References: <20070504221555.642061626@sgi.com>
 <20070504221708.363027097@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

clameter@sgi.com wrote:
> +	if (ctor || dtor) {
> +		so = kzalloc(sizeof(struct slab_ops), GFP_KERNEL);
> +		so->ctor = ctor;
> +		so->dtor = dtor;
> +	}
> +	return  __kmem_cache_create(s, size, align, flags, so);
Is this a memory leak?

Regards
Bert Wesarg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
