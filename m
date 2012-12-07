Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id C023D6B005D
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 18:51:26 -0500 (EST)
Date: Fri, 7 Dec 2012 15:51:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add node physical memory range to sysfs
Message-Id: <20121207155125.d3117244.akpm@linux-foundation.org>
In-Reply-To: <1354919696.2523.6.camel@buesod1.americas.hpqcorp.net>
References: <1354919696.2523.6.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 07 Dec 2012 14:34:56 -0800
Davidlohr Bueso <davidlohr.bueso@hp.com> wrote:

> This patch adds a new 'memrange' file that shows the starting and
> ending physical addresses that are associated to a node. This is
> useful for identifying specific DIMMs within the system.

I was going to bug you about docmentation, but apparently we didn't
document /sys/devices/system/node/node*/.  A great labor-saving device,
that!

> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -211,6 +211,19 @@ static ssize_t node_read_distance(struct device *dev,
>  }
>  static DEVICE_ATTR(distance, S_IRUGO, node_read_distance, NULL);
>  
> +static ssize_t node_read_memrange(struct device *dev,
> +				  struct device_attribute *attr, char *buf)
> +{
> +	int nid = dev->id;
> +	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
> +	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;

hm.  Is this correct for all for
FLATMEM/SPARSEMEM/SPARSEMEM_VMEMMAP/DISCONTIGME/etc?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
