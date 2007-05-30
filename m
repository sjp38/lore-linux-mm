Subject: Re: [PATCH] Make dynamic/run-time configuration of zonelist order
	configurable
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070530111212.095350d2.akpm@linux-foundation.org>
References: <1180468121.5067.64.camel@localhost>
	 <20070530111212.095350d2.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 30 May 2007 15:42:22 -0400
Message-Id: <1180554142.5850.90.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-30 at 11:12 -0700, Andrew Morton wrote:
> On Tue, 29 May 2007 15:48:41 -0400
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > [PATCH] Make dynamic/run-time configuration of zonelist order configurable
> > 
> > Against 2.6.22-rc2-mm1 with the huge page allocation fix applied:
> > 
> > 	http://marc.info/?l=linux-mm&m=117935390224779&w=4
> > 
> 
> I wasn't cc'ed on "[PATCH/RFC] Fix hugetlb pool allocation with empty nodes
> - V4" so I didn't apply it hence cannot apply this.

My send folder should you copied on the patch referenced by the link
above, but that doesn't mean you got it... As far as the status of that
patch, I'm still unclear on Nish's testing.  He ack'd for x86_64 where
he had a problem that V4 was supposed to fix, but couldn't test on ppc.
So, I didn't think he's ready for it to go in.

> 
> Plus I'd prefer not to, really.  This patch should be folded into
> change-zonelist-order-zonelist-order-selection-logic.patch somehow, but I
> cannot do that if it is dependent upon the unrelated "[PATCH/RFC] Fix
> hugetlb pool allocation with empty nodes - V4".

Well, I really didn't expect this one to go right in.  We needed to hear
from Kame first.  Probably should have added an 'RFC'...

> 
> Better would be to raise a patch relative to the change-zonelist-order-*
> patches, please.  Then we can take a look at the hugetlb fix independently.

zonelist order stuff is already in 22-rc2-mm and I considered holding
off on this patch until Nish ack'd or nack'd the hugetlb fix.  Sorry for
the confusion.  But, before I go and rework it against the current mm
tree and then rebase the hugetlb fix on that, could you offer an opinion
either way, whether it's worth the effort and a new Kconfig option to
attempt to give back this amount init code/data?  I recall you making
noise about the zonelist order patch being "a lot of code" when Kame
first posted it.

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
