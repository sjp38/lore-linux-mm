Date: Fri, 24 Oct 2008 07:34:02 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
Message-ID: <20081024053402.GA11725@wotan.suse.de>
References: <20081024135149.9C46.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081024045547.GA24555@wotan.suse.de> <20081024140723.9C49.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081024140723.9C49.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 24, 2008 at 02:29:18PM +0900, KOSAKI Motohiro wrote:
> > > > I don't see a better way to solve it, other than avoiding lru_add_drain_all
> > > 
> > > Well,
> > > 
> > > Unfortunately, lru_add_drain_all is also used some other VM place
> > > (page migration and memory hotplug).
> > > and page migration's usage is the same of this mlock usage.
> > > (1. grab mmap_sem  2.  call lru_add_drain_all)
> > > 
> > > Then, change mlock usage isn't solution ;-)
> > 
> > No, not mlock alone.
> 
> Ah, I see.
> It seems difficult but valuable. I'll think this way for a while.

Well, I think it would be nice if we can reduce lru_add_drain_all,
however your patch might be the least intrusive and best short term
solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
