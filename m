Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E53056B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 10:55:37 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D6CAF82C53F
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 10:58:11 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2L-PjdGY6DSZ for <linux-mm@kvack.org>;
	Wed,  4 Feb 2009 10:58:11 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id ADCFE82C535
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 10:57:33 -0500 (EST)
Date: Wed, 4 Feb 2009 10:48:29 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator (try 2)
In-Reply-To: <200902032250.55968.nickpiggin@yahoo.com.au>
Message-ID: <alpine.DEB.1.10.0902041048140.19633@qirst.com>
References: <20090123154653.GA14517@wotan.suse.de> <200902032136.26022.nickpiggin@yahoo.com.au> <20090203112852.GJ9840@csn.ul.ie> <200902032250.55968.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@csn.ul.ie>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009, Nick Piggin wrote:

> > Just to clarify on this last point, do you mean slub_max_order=0 to
> > force order-0 allocations in SLUB?
>
> Hmm... I think slub_min_objects=1 should also do basically the same.
> Actually slub_min_object=1 and slub_max_order=1 should get closest I
> think.

slub_max_order=0 would be sufficient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
