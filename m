Date: Wed, 30 May 2007 10:33:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 7/7] Add /proc/sys/vm/compact_node for the explicit
 compaction of a node
In-Reply-To: <Pine.LNX.4.64.0705300920150.16108@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705301031210.1195@schroedinger.engr.sgi.com>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
 <20070529173830.1570.91184.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705292109460.29854@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705300920150.16108@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 30 May 2007, Mel Gorman wrote:

> > Check for node < nr_node_ids first.
> Very good point. Will fix

And check if the node is online first? F.e.

node_online(node) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
