Subject: Re: [PATCH] Make dynamic/run-time configuration of zonelist order
	configurable
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070530130911.431d5f6f.akpm@linux-foundation.org>
References: <1180468121.5067.64.camel@localhost>
	 <20070530111212.095350d2.akpm@linux-foundation.org>
	 <1180554142.5850.90.camel@localhost>
	 <20070530130911.431d5f6f.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 31 May 2007 10:58:43 -0400
Message-Id: <1180623523.5091.32.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-30 at 13:09 -0700, Andrew Morton wrote:
> On Wed, 30 May 2007 15:42:22 -0400
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > But, before I go and rework it against the current mm
> > tree and then rebase the hugetlb fix on that, could you offer an opinion
> > either way, whether it's worth the effort and a new Kconfig option to
> > attempt to give back this amount init code/data?  I recall you making
> > noise about the zonelist order patch being "a lot of code" when Kame
> > first posted it.
> 
> The concern with a "lot of code" is 99% about complexity, reliability and
> maintainability and only 1% about RAM usage.

Ah, OK.

> 
> This stuff is mainly a NUMA/SMP thing, isn't it?  If so, a couple of k is
> neither here nor there.

I agree that on the platforms I deal with, it's not an issue.  However,
as I mentioned, I've seen chatter on the lists from folks who apparently
use numa emulation [requires NUMA infrastructure] on single cpu 32-bit
systems as a "poor man's containers" for memory resource management and
didn't want to impose the addtional, admittedly small, extra overhead on
them.  Perhaps this usage goes away when containers becomes mainline.
If no one in that camp complains and you don't think it's worth it, I'll
drop it.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
