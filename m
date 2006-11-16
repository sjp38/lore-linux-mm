Date: Wed, 15 Nov 2006 21:28:35 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have no memory
Message-ID: <20061116032835.GA25299@sgi.com>
References: <20061115193049.3457b44c@localhost> <20061115193437.25cdc371@localhost> <Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com> <20061115215845.GB20526@sgi.com> <Pine.LNX.4.64.0611151432050.23201@schroedinger.engr.sgi.com> <20061116013534.GB1066@sgi.com> <Pine.LNX.4.64.0611151754480.24793@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0611151754480.24793@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christian Krafft <krafft@de.ibm.com>, linux-mm@kvack.org, Martin Bligh <mbligh@mbligh.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 15, 2006 at 05:57:27PM -0800, Christoph Lameter wrote:
> On Wed, 15 Nov 2006, Jack Steiner wrote:
> 
> > I doubt that there is a demand for systems with memoryless nodes. However, if the
> > DIMM(s) on a node fails, I think the system may perform better
> > with the cpus on the node enabled than it will if they have to be
> > disabled.
> 
> Right now we do not have the capability to remove memory from a node while 
> the system is running.

I know. I'm refering to a DIMM that fails power-on diags or one
that is explicitly disabled from the system controller.

Clearly a reboot is required in both cases, but the end result is
a node with cpus and no memory. As I said earlier, the PROM (for several 
reasons) automatically the cpus on nodes w/o memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
