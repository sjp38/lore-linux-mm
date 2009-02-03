Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D5EF25F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 06:58:03 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator (try 2)
Date: Tue, 3 Feb 2009 22:50:54 +1100
References: <20090123154653.GA14517@wotan.suse.de> <200902032136.26022.nickpiggin@yahoo.com.au> <20090203112852.GJ9840@csn.ul.ie>
In-Reply-To: <20090203112852.GJ9840@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902032250.55968.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 03 February 2009 22:28:52 Mel Gorman wrote:
> On Tue, Feb 03, 2009 at 09:36:24PM +1100, Nick Piggin wrote:

> > I'd be interested to see how slub performs if booted with
> > slub_min_objects=1 (which should give similar order pages to SLAB and
> > SLQB).
>
> Just to clarify on this last point, do you mean slub_max_order=0 to
> force order-0 allocations in SLUB?

Hmm... I think slub_min_objects=1 should also do basically the same.
Actually slub_min_object=1 and slub_max_order=1 should get closest I
think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
