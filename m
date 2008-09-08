Date: Mon, 8 Sep 2008 11:36:19 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Message-ID: <20080908093619.GC26079@one.firstfloor.org>
References: <20080905215452.GF11692@us.ibm.com> <20080906153855.7260.E1E9C6FF@jp.fujitsu.com> <20080906085320.GE18288@one.firstfloor.org> <200809081552.50126.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200809081552.50126.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> You use non-linear mappings for the kernel, so that kernel data is
> not tied to a specific physical address. AFAIK, that is the only way
> to really do it completely (like the fragmentation problem).

Even with that there are lots of issues, like keeping track of 
DMAs or handling executing kernel code.

> 
> Of course, I don't think that would be a good idea to do that in the
> forseeable future.

Agreed.

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
