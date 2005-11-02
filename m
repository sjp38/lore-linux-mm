Date: Wed, 02 Nov 2005 17:33:08 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
In-Reply-To: <436877DB.7020808@yahoo.com.au>
References: <1130917338.14475.133.camel@localhost> <436877DB.7020808@yahoo.com.au>
Message-Id: <20051102172729.9E7C.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Dave Hansen <haveblue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

> > One other thing, if we decide to take the zones approach, it would have
> > no other side benefits for the kernel.  It would be for hotplug only and
> > I don't think even the large page users would get much benefit.  
> > 
> 
> Hugepage users? They can be satisfied with ZONE_REMOVABLE too. If you're
> talking about other higher-order users, I still think we can't guarantee
> past about order 1 or 2 with Mel's patch and they simply need to have
> some other ways to do things.

Hmmm. I don't see at this point.
Why do you think ZONE_REMOVABLE can satisfy for hugepage.
At leaset, my ZONE_REMOVABLE patch doesn't any concern about
fragmentation.

Bye.

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
