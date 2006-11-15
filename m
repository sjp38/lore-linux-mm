Message-ID: <455B9825.3030403@mbligh.org>
Date: Wed, 15 Nov 2006 14:43:49 -0800
From: Martin Bligh <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have
 no memory
References: <20061115193049.3457b44c@localhost> <20061115193437.25cdc371@localhost> <Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com> <20061115215845.GB20526@sgi.com> <Pine.LNX.4.64.0611151432050.23201@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611151432050.23201@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Christian Krafft <krafft@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 15 Nov 2006, Jack Steiner wrote:
> 
>> A lot of the core infrastructure is currently missing that is required
>> to describe IO nodes as regular nodes, but in principle, I don't
>> see anything wrong with nodes w/o memory.
> 
> Every processor has a local node on which it runs. The kernel places 
> memory used by the processor on the local node. Even if we allow
> nodes without memory: We still need to associate a "local" node to the 
> processor. If that is across some NUMA interlink then it is going to be 
> slower but it will work.
> 
> AFAIK It seems to be better to explicitly associate a memory node with a 
> processor during bootup in arch code. 
> 
> Various kernel optimizations rely on local memory. Would we create 
> a  special case here of a pglist_data structure without a zones structure? 
> 
> It seems that the contents of pglist_data are targeted to a memory node. 
> If we do not have a pglist_data structure then the node would not exist 
> for the kernel.
> 
> What would the benefit or difference be of having nodes without memory?

Some nodes really don't have memory. Either because it's been
deconfigured, or because it was never there in the first place.
We shouldn't need to kludge that.

All we need is an appropriate zonelist for each node, pointing to
the memory it should be accessing.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
