Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m85LtJSO032716
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 17:55:19 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m85LtD38201834
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 15:55:18 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m85LtCbN015376
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 15:55:13 -0600
Date: Fri, 5 Sep 2008 14:54:52 -0700
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Message-ID: <20080905215452.GF11692@us.ibm.com>
References: <20080905172132.GA11692@us.ibm.com> <87ej3yv588.fsf@basil.nowhere.org> <20080905195314.GE11692@us.ibm.com> <20080905200401.GA18288@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080905200401.GA18288@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 05, 2008 at 10:04:01PM +0200, Andi Kleen wrote:
> > The inability to offline all non-primary node memory sections
> > certainly needs to be addressed.  The pgdat removal work that
> > Yasunori Goto has started will hopefully continue and help resolve
> > this issue. 
> 
> You make it sound like it's just some minor technical hurdle
> that needs to be addressed.

Sorry, that was not my intent.

> But from all analysis of these issues
> I've seen so far it's extremly hard and all possible solutions
> have serious issues. So before doing some baby steps there
> should be at least some general idea how this thing is supposed
> to work in the end.

I am not sure if I understand why you appear to be opposed to
enabling the hotremove function before all the issues related
to an eventual goal of being able to free all memory on a node
are addressed.  Even in the absence of solutions for these issues
it seems like there could still be other possible benefits such
as the ability to selectively expand and shrink available memory
for testing or debugging purposes.  I believe it would also be
helpful to those working on or testing possible solutions for
the removal issues.

Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
