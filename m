Date: Wed, 8 Nov 2006 11:40:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] add dev_to_node()
Message-Id: <20061108114038.59831f9d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061104225629.GA31437@lst.de>
References: <20061030141501.GC7164@lst.de>
	<20061030.143357.130208425.davem@davemloft.net>
	<20061104225629.GA31437@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, I have a question.

On Sat, 4 Nov 2006 23:56:29 +0100
Christoph Hellwig <hch@lst.de> wrote:
> Index: linux-2.6/include/linux/device.h
> ===================================================================
> --- linux-2.6.orig/include/linux/device.h	2006-10-29 16:02:38.000000000 +0100
> +++ linux-2.6/include/linux/device.h	2006-11-02 12:47:17.000000000 +0100
> @@ -347,6 +347,9 @@
>  					   BIOS data),reserved for device core*/
>  	struct dev_pm_info	power;
>  
> +#ifdef CONFIG_NUMA
> +	int		numa_node;	/* NUMA node this device is close to */
> +#endif

> +	dev->dev.numa_node = pcibus_to_node(bus);

Does this "node" is guaranteed to be online ?

if node is not online, NODE_DATA(node) is NULL or not initialized.
Then, alloc_pages_node() at el. will panic.

I wonder there are no code for creating NODE_DATA() for device-only-node.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
