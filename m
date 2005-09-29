Date: Thu, 29 Sep 2005 10:06:23 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [patch] bug of pgdat_list connection in init_bootmem()
In-Reply-To: <1127925735.10315.232.camel@localhost>
References: <20050928223844.8655.Y-GOTO@jp.fujitsu.com> <1127925735.10315.232.camel@localhost>
Message-Id: <20050929095955.7ACF.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 2005-09-28 at 22:50 +0900, Yasunori Goto wrote:
> >   I would like to remove this pgdat_list, to simplify hot-add/remove
> >   a node. and posted patch before.
> >    http://marc.theaimsgroup.com/?l=linux-mm&m=111596924629564&w=2
> >    http://marc.theaimsgroup.com/?l=linux-mm&m=111596953711780&w=2
> > 
> >   I would like to repost after getting performance impact by this.
> >   But it is very hard that I can get time to use big NUMA machine now.
> >   So, I don't know when I will be able to repost it.
> > 
> >   Anyway, this should be modified before remove pgdat_list.
> 
> Could you resync those to a current kernel and resend them?  I'll take
> them into -mhp for a bit.
> 
> I'd be very skeptical that it would hurt performance.  If nothing else,
> it just makes the pgdat smaller, and the likelyhood of having the next
> bit in a bitmask and the NODE_DATA() entry in your cache is slightly
> higher than some random pgdat->list.

Ok! I'll do it. :-)

Thanks.

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
