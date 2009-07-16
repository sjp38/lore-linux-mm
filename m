Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 16C336B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 14:17:45 -0400 (EDT)
Date: Thu, 16 Jul 2009 20:17:45 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] hugetlb:  restore interleaving of bootmem huge pages
Message-ID: <20090716181745.GF8046@one.firstfloor.org>
References: <1247754662.4382.51.camel@useless.americas.hpqcorp.net> <20090716173158.GB9507@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090716173158.GB9507@shadowen.org>
Sender: owner-linux-mm@kvack.org
To: Andy Whitcroft <apw@canonical.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Eric Whitney <eric.whitney@hp.com>, linux-numa <linux-numa@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> It looks like this behaviour was in the original implementation to my eye.
> It does indeed seem to prefer taking all it can from one node before moving
> on to the next.  Your change seems reasonable to my eye though it may be
> worth asking Andi if it was intended.  The intent of this change seems
> to bring the behaviour into line with that of alloc_fresh_huge_page()
> used for orders less than MAX_ORDER.

I don't remember intending it this way. The intention was always
standard round robin one by one. If it didn't do that it wasn't extended.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
