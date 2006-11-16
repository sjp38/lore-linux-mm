Date: Thu, 16 Nov 2006 10:22:05 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have no memory
In-Reply-To: <20061116095945.e6ad4440.kamezawa.hiroyu@jp.fujitsu.com>
References: <Pine.LNX.4.64.0611151450550.23477@schroedinger.engr.sgi.com> <20061116095945.e6ad4440.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20061116101358.2CB6.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: mbligh@mbligh.org, krafft@de.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> I hear some vender's machine has this configuration. (ia64, maybe SGI or HP)
> 
> Node0: CPUx0 + XXXGb memory
> Node1: CPUx2 + 16MB memory
> Node2: CPUx2 + 16MB memory
> 
> memory of Node1 and Node2 is tirmmed at boot by GRANULE alignment.
> Then, final view is
> Node0 : memory-only-node
> Node1 : cpu-only-node
> Node2 : cpu-only-node.

IIRC, this is HP box. It is using memory interleave among nodes.

Bye.
-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
