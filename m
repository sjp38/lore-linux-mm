Date: Tue, 31 Oct 2006 17:58:31 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/3] add dev_to_node()
In-Reply-To: <20061031.165314.39158827.davem@davemloft.net>
Message-ID: <Pine.LNX.4.64.0610311757040.8656@schroedinger.engr.sgi.com>
References: <20061030141501.GC7164@lst.de> <20061030.143357.130208425.davem@davemloft.net>
 <Pine.LNX.4.64.0610311610150.7609@schroedinger.engr.sgi.com>
 <20061031.165314.39158827.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: hch@lst.de, linux-kernel@vger.kernel.org, netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Oct 2006, David Miller wrote:

> Yes, that's possible, because the idea is that the arch specific
> bus layer code would initialize the node value.  Therefore, there
> would be no need for things like pcibus_to_node() any longer.

Then lets rename pcibus_to_node to dev_to_node() throughout the kernel. 
Provide a -1 default. Then other device layers that are not based on pci 
will also be able to exploit NUMA locality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
