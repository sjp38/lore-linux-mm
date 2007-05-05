Received: by ug-out-1314.google.com with SMTP id s2so679397uge
        for <linux-mm@kvack.org>; Sat, 05 May 2007 03:14:07 -0700 (PDT)
Message-ID: <84144f020705050314s36510c98j70d1ca8e3770f00e@mail.gmail.com>
Date: Sat, 5 May 2007 13:14:07 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC 1/3] SLUB: slab_ops instead of constructors / destructors
In-Reply-To: <20070504221708.363027097@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070504221555.642061626@sgi.com>
	 <20070504221708.363027097@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On 5/5/07, clameter@sgi.com <clameter@sgi.com> wrote:
> This patch gets rid constructors and destructors and replaces them
> with a slab operations structure that is passed into SLUB.

Looks good to me.

On 5/5/07, clameter@sgi.com <clameter@sgi.com> wrote:
> +struct slab_ops {
> +       /* FIXME: ctor should only take the object as an argument. */
> +       void (*ctor)(void *, struct kmem_cache *, unsigned long);
> +       /* FIXME: Remove all destructors ? */
> +       void (*dtor)(void *, struct kmem_cache *, unsigned long);
> +};

For consistency with other operations structures, can we make this
struct kmem_cache_operations or kmem_cache_ops, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
