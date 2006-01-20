Date: Fri, 20 Jan 2006 17:22:42 +0900
From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Subject: Re: [PATCH 1/2] Add the pzone
In-Reply-To: <43D08C6C.1000802@jp.fujitsu.com>
References: <20060119080408.24736.13148.sendpatchset@debian>
	<20060119080413.24736.27946.sendpatchset@debian>
	<43D08C6C.1000802@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20060120082242.8BEE57402D@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Jan 2006 16:08:28 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> >  include/linux/gfp.h    |    3 
> >  include/linux/mm.h     |   49 ++
> >  include/linux/mmzone.h |  118 ++++++
> >  include/linux/swap.h   |    2 
> >  mm/Kconfig             |    6 
> >  mm/page_alloc.c        |  845 +++++++++++++++++++++++++++++++++++++++++++++----
> >  mm/shmem.c             |    2 
> >  mm/vmscan.c            |   75 +++-
> >  8 files changed, 1020 insertions(+), 80 deletions(-)
> Could you divide this *large* patch to several pieces ?

Ok, I'll split the patch.

> It looks you don't want to use functions based on zones, buddy-system, lru-list etc..
> I think what you want is just a hierarchical memory allocator.
> Why do you modify zone and make codes complicated ?
> Can your memory allocater be implimented like mempool or hugetlb ?
> They are not so invasive.

mempool and hugetlb require their own shrinking code, don't they?
I guess that we would need the routines like mm/vmscan.c if we are
going to shrink user pages.  Instead, I'd like to reuse the shrinking
code in mm/vmscan.c.

Thanks,

-- 
KUROSAWA, Takahiro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
