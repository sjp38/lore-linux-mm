From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/6] mm: add kmalloc_array_node and kcalloc_node
Date: Wed, 27 Sep 2017 03:56:40 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709270355400.30866@nuc-kabylake>
References: <20170927082038.3782-1-jthumshirn@suse.de> <20170927082038.3782-2-jthumshirn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927082038.3782-2-jthumshirn@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Damien Le Moal <damien.lemoal@wdc.com>, Christoph Hellwig <hch@lst.de>
List-Id: linux-mm.kvack.org

On Wed, 27 Sep 2017, Johannes Thumshirn wrote:

> +static inline void *kmalloc_array_node(size_t n, size_t size, gfp_t flags,
> +				       int node)
> +{
> +	if (size != 0 && n > SIZE_MAX / size)
> +		return NULL;
> +	if (__builtin_constant_p(n) && __builtin_constant_p(size))
> +		return kmalloc_node(n * size, flags, node);

Isnt the same check done by kmalloc_node already? The result of
multiplying two constants is a constant after all.
