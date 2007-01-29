Date: Mon, 29 Jan 2007 14:36:54 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
 movable and non-movable pages
Message-Id: <20070129143654.27fcd4a4.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0701291349450.548@schroedinger.engr.sgi.com>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
	<20070126030753.03529e7a.akpm@osdl.org>
	<Pine.LNX.4.64.0701260751230.6141@schroedinger.engr.sgi.com>
	<20070126114615.5aa9e213.akpm@osdl.org>
	<Pine.LNX.4.64.0701261147300.15394@schroedinger.engr.sgi.com>
	<20070126122747.dde74c97.akpm@osdl.org>
	<Pine.LNX.4.64.0701291349450.548@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007 13:54:38 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 26 Jan 2007, Andrew Morton wrote:
> 
> > > The main benefit is a significant simplification of the VM, leading to 
> > > robust and reliable operations and a reduction of the maintenance 
> > > headaches coming with the additional zones.
> > > 
> > > If we would introduce the ability of allocating from a range of 
> > > physical addresses then the need for DMA zones would go away allowing 
> > > flexibility for device driver DMA allocations and at the same time we get 
> > > rid of special casing in the VM.
> > 
> > None of this is valid.  The great majority of machines out there will
> > continue to have the same number of zones.  Nothing changes.
> 
> All 64 bit machine will only have a single zone if we have such a range 
> alloc mechanism. The 32bit ones with HIGHMEM wont be able to avoid it, 
> true. But all arches that do not need gymnastics to access their memory 
> will be able run with a single zone.

What is "such a range alloc mechanism"?

> > That's all a real cost, so we need to see *good* benefits to outweigh that
> > cost.  Thus far I don't think we've seen that.
> 
> The real savings is the simplicity of VM design, robustness and 
> efficiency. We loose on all these fronts if we keep or add useless zones. 
> 
> The main reason for the recent problems with dirty handling seem to be due 
> to exactly such a multizone balancing issues involving ZONE_NORMAL and 
> HIGHMEM. Those problems cannot occur on single ZONE arches (this means 
> right now on a series of embedded arches, UML and IA64). 
> 
> Multiple ZONES are a recipie for VM fragility and result in complexity 
> that is difficult to manage.

Why do I have to keep repeating myself?  90% of known FC6-running machines
are x86-32.  90% of vendor-shipped kernels need all three zones.  And the
remaining 10% ship with multiple nodes as well.

So please stop telling me what a wonderful world it is to not have multiple
zones.  It just isn't going to happen for a long long time.  The
multiple-zone kernel is the case we need to care about most by a very large
margin indeed.  Single-zone is an infinitesimal corner-case.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
