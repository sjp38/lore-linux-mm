Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D7CC56B00A4
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 12:24:54 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator (try 2)
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <alpine.DEB.1.10.0902171204070.15929@qirst.com>
References: <20090123154653.GA14517@wotan.suse.de>
	 <200902041748.41801.nickpiggin@yahoo.com.au>
	 <20090204152709.GA4799@csn.ul.ie>
	 <200902051459.30064.nickpiggin@yahoo.com.au>
	 <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi>
	 <alpine.DEB.1.10.0902171120040.27813@qirst.com>
	 <1234890096.11511.6.camel@penberg-laptop>
	 <alpine.DEB.1.10.0902171204070.15929@qirst.com>
Date: Tue, 17 Feb 2009 19:24:52 +0200
Message-Id: <1234891492.11511.8.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-02-17 at 12:05 -0500, Christoph Lameter wrote:
> Well yes you missed two locations (kmalloc_caches array has to be
> redimensioned) and I also was writing the same patch...

:-)

On Tue, 2009-02-17 at 12:05 -0500, Christoph Lameter wrote:
> Subject: SLUB: Do not pass 8k objects through to the page allocator
> 
> Increase the maximum object size in SLUB so that 8k objects are not
> passed through to the page allocator anymore. The network stack uses 8k
> objects for performance critical operations.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Looks good to me. Yanmin, please retest netperf with this one instead if
you have the time. I'll replace the revert with this patch but keep your
default order tweak patch.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
