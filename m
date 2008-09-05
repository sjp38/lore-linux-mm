Date: Fri, 5 Sep 2008 22:04:01 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Message-ID: <20080905200401.GA18288@one.firstfloor.org>
References: <20080905172132.GA11692@us.ibm.com> <87ej3yv588.fsf@basil.nowhere.org> <20080905195314.GE11692@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080905195314.GE11692@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> The inability to offline all non-primary node memory sections
> certainly needs to be addressed.  The pgdat removal work that
> Yasunori Goto has started will hopefully continue and help resolve
> this issue. 

You make it sound like it's just some minor technical hurdle
that needs to be addressed. But from all analysis of these issues
I've seen so far it's extremly hard and all possible solutions
have serious issues. So before doing some baby steps there
should be at least some general idea how this thing is supposed
to work in the end.

> We have only just started thinking about issues related
> to resources other that CPUs and memory that will need to be released
> in preparation for node removal (e.g. memory and i/o resources
> assigned to PCI devices on a node targeted for removal). 

That's the easy stuff. The hard parts are all the kernel objects
that you cannot move.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
