Date: Tue, 31 Oct 2006 16:53:14 -0800 (PST)
Message-Id: <20061031.165314.39158827.davem@davemloft.net>
Subject: Re: [PATCH 2/3] add dev_to_node()
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610311610150.7609@schroedinger.engr.sgi.com>
References: <20061030141501.GC7164@lst.de>
	<20061030.143357.130208425.davem@davemloft.net>
	<Pine.LNX.4.64.0610311610150.7609@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 31 Oct 2006 16:10:48 -0800 (PST)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: hch@lst.de, linux-kernel@vger.kernel.org, netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 30 Oct 2006, David Miller wrote:
> 
> > So, please add some sanity to this situation and just put the node
> > into the generic struct device. :-)
> 
> Good. Then we can remove the node from the pci structure and get rid of 
> pcibus_to_node?

Yes, that's possible, because the idea is that the arch specific
bus layer code would initialize the node value.  Therefore, there
would be no need for things like pcibus_to_node() any longer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
