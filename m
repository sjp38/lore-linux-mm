Received: by wa-out-1112.google.com with SMTP id m33so2405266wag
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 13:16:33 -0700 (PDT)
Message-ID: <84144f020706181316u70145db2i786641d265e5bc42@mail.gmail.com>
Date: Mon, 18 Jun 2007 23:16:33 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 05/26] Slab allocators: Cleanup zeroing allocations
In-Reply-To: <20070618095914.622685354@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <20070618095914.622685354@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 6/18/07, clameter@sgi.com <clameter@sgi.com> wrote:
> +static inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
> +{
> +       return kmem_cache_alloc(k, flags | __GFP_ZERO);
> +}
> +
> +static inline void *__kzalloc(int size, gfp_t flags)
> +{
> +       return kmalloc(size, flags | __GFP_ZERO);
> +}

Hmm, did you check kernel text size before and after this change?
Setting the __GFP_ZERO flag at every kzalloc call-site seems like a
bad idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
