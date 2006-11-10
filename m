Date: Fri, 10 Nov 2006 10:16:35 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/3] add dev_to_node()
In-Reply-To: <20061108114038.59831f9d.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0611101015060.25338@schroedinger.engr.sgi.com>
References: <20061030141501.GC7164@lst.de> <20061030.143357.130208425.davem@davemloft.net>
 <20061104225629.GA31437@lst.de> <20061108114038.59831f9d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Hellwig <hch@lst.de>, davem@davemloft.net, linux-kernel@vger.kernel.org, netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Nov 2006, KAMEZAWA Hiroyuki wrote:

> I wonder there are no code for creating NODE_DATA() for device-only-node.

On IA64 we remap nodes with no memory / cpus to the nearest node with 
memory. I think that is sufficient.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
