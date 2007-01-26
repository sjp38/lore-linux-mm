Date: Fri, 26 Jan 2007 03:07:53 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
 movable and non-movable pages
Message-Id: <20070126030753.03529e7a.akpm@osdl.org>
In-Reply-To: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jan 2007 23:44:58 +0000 (GMT)
Mel Gorman <mel@csn.ul.ie> wrote:

> The following 8 patches against 2.6.20-rc4-mm1 create a zone called
> ZONE_MOVABLE

Argh.  These surely get all tangled up with the
make-zones-optional-by-adding-zillions-of-ifdef patches:

deal-with-cases-of-zone_dma-meaning-the-first-zone.patch
introduce-config_zone_dma.patch
optional-zone_dma-in-the-vm.patch
optional-zone_dma-in-the-vm-no-gfp_dma-check-in-the-slab-if-no-config_zone_dma-is-set.patch
optional-zone_dma-in-the-vm-no-gfp_dma-check-in-the-slab-if-no-config_zone_dma-is-set-reduce-config_zone_dma-ifdefs.patch
optional-zone_dma-for-ia64.patch
remove-zone_dma-remains-from-parisc.patch
remove-zone_dma-remains-from-sh-sh64.patch
set-config_zone_dma-for-arches-with-generic_isa_dma.patch
zoneid-fix-up-calculations-for-zoneid_pgshift.patch

My objections to those patches:

- They add zillions of ifdefs

- They make the VM's behaviour diverge between different platforms and
  between differen configs on the same platforms, and hence degrade
  maintainability and increase complexity.

- We kicked around some quite different ways of implementing the same
  things, but nothing came of it.  iirc, one was to remove the hard-coded
  zones altogether and rework all the MM to operate in terms of

	for (idx = 0; idx < NUMBER_OF_ZONES; idx++)
		...

- I haven't seen any hard numbers to justify the change.

So I want to drop them all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
