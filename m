Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2071B5F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 10:04:59 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5EA4082C31C
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 10:07:20 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id OH0dVd4ycX6R for <linux-mm@kvack.org>;
	Mon,  2 Feb 2009 10:07:20 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 72A5B82C368
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 10:07:15 -0500 (EST)
Date: Mon, 2 Feb 2009 10:00:04 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <1233565214.17835.13.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0902020955490.1549@qirst.com>
References: <20090121143008.GV24891@wotan.suse.de>  <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>  <84144f020901220201g6bdc2d5maf3395fc8b21fe67@mail.gmail.com>  <Pine.LNX.4.64.0901221239260.21677@blonde.anvils>  <Pine.LNX.4.64.0901231357250.9011@blonde.anvils>
  <1233545923.2604.60.camel@ymzhang> <1233565214.17835.13.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Feb 2009, Pekka Enberg wrote:

> Hi Yanmin,
>
> On Mon, 2009-02-02 at 11:38 +0800, Zhang, Yanmin wrote:
> > Can we add a checking about free memory page number/percentage in function
> > allocate_slab that we can bypass the first try of alloc_pages when memory
> > is hungry?
>
> If the check isn't too expensive, I don't any reason not to. How would
> you go about checking how much free pages there are, though? Is there
> something in the page allocator that we can use for this?

If the free memory is low then reclaim needs to be run to increase the
free memory. Falling back immediately incurs the overhead of going through
the order 0 queues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
