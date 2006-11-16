Date: Thu, 16 Nov 2006 09:54:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have
 no memory
Message-Id: <20061116095429.0e6109a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0611151451450.23477@schroedinger.engr.sgi.com>
References: <20061115193049.3457b44c@localhost>
	<20061115193437.25cdc371@localhost>
	<Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
	<20061115215845.GB20526@sgi.com>
	<Pine.LNX.4.64.0611151432050.23201@schroedinger.engr.sgi.com>
	<455B9825.3030403@mbligh.org>
	<Pine.LNX.4.64.0611151451450.23477@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: mbligh@mbligh.org, steiner@sgi.com, krafft@de.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Nov 2006 14:52:43 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 15 Nov 2006, Martin Bligh wrote:
> 
> > All we need is an appropriate zonelist for each node, pointing to
> > the memory it should be accessing.
> 
> But there is no memory on the node. Does the zonelist contain the zones of 
> the node without memory or not? We simply fall back each allocation to the 
> next node as if the node was overflowing?
> 
yes. just fallback.
The zonelist[] donen't contain empty-zone.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
