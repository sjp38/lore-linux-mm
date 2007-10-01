Date: Mon, 1 Oct 2007 13:34:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch / 002](memory hotplug) Callback function to create
 kmem_cache_node.
In-Reply-To: <20071001183316.7A9B.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0710011334090.19779@schroedinger.engr.sgi.com>
References: <20071001182329.7A97.Y-GOTO@jp.fujitsu.com>
 <20071001183316.7A9B.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Oct 2007, Yasunori Goto wrote:

> +#ifdef CONFIG_MEMORY_HOTPLUG
> +static void __slab_callback_offline(int nid)
> +{
> +	struct kmem_cache_node *n;
> +	struct kmem_cache *s;
> +
> +	list_for_each_entry(s, &slab_caches, list) {
> +		if (s->node[nid]) {
> +			n = get_node(s, nid);
> +			s->node[nid] = NULL;
> +			kmem_cache_free(kmalloc_caches, n);
> +		}
> +	}
> +}

I think we need to bug here if there are still objects on the node that 
are in use. This will silently discard the objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
