Date: Sat, 11 Nov 2006 09:08:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] add dev_to_node()
Message-Id: <20061111090851.73d4d3b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1163183306.15159.6.camel@localhost>
References: <20061030141501.GC7164@lst.de>
	<20061030.143357.130208425.davem@davemloft.net>
	<20061104225629.GA31437@lst.de>
	<20061108114038.59831f9d.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0611101015060.25338@schroedinger.engr.sgi.com>
	<1163183306.15159.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: clameter@sgi.com, hch@lst.de, davem@davemloft.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Nov 2006 13:28:25 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> On Fri, 2006-11-10 at 10:16 -0800, Christoph Lameter wrote:
> > On Wed, 8 Nov 2006, KAMEZAWA Hiroyuki wrote:
> > 
> > > I wonder there are no code for creating NODE_DATA() for device-only-node.
> > 
> > On IA64 we remap nodes with no memory / cpus to the nearest node with 
> > memory. I think that is sufficient.
> 
> I don't think this happens anymore.  

In my understanding , from drivers/acpi/numa.c, 
a node is created by a pxm found in SRAT table at boot time.

the node-number for the pxm which was not found in SRAT at boot time is "-1".
please check how acpi_map_pxm_to_node() is used.

If pci's node-id is based on pxm, checking return vaule of pxm_to_node() 
will be good.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
