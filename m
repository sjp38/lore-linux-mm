Date: Wed, 15 Nov 2006 15:15:35 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/3] add numa node information to struct device
Message-Id: <20061115151535.ef1beadb.akpm@osdl.org>
In-Reply-To: <20061115173701.GB18244@lst.de>
References: <20061115173701.GB18244@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Nov 2006 18:37:01 +0100
Christoph Hellwig <hch@lst.de> wrote:

> +#ifdef CONFIG_NUMA
> +#define dev_to_node(dev)	((dev)->numa_node)
> +#define set_dev_node(dev, node)	((dev)->numa_node = node)
> +#else
> +#define dev_to_node(dev)	(-1)
> +#define set_dev_node(dev, node)	do { } while (0)
> +#endif

minor point: using inlines here would give typechecking, prevent possible
unused-var warnings, etc.

Maybe there was a reason for not doing that.

<does it>

No doubt I'll find out ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
