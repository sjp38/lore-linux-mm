Message-ID: <43D08C6C.1000802@jp.fujitsu.com>
Date: Fri, 20 Jan 2006 16:08:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Add the pzone
References: <20060119080408.24736.13148.sendpatchset@debian> <20060119080413.24736.27946.sendpatchset@debian>
In-Reply-To: <20060119080413.24736.27946.sendpatchset@debian>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KUROSAWA Takahiro wrote:
> This patch implements the pzone (pseudo zone).  A pzone can be used
> for reserving pages in a zone.  Pzones are implemented by extending
> the zone structure and act almost the same as the conventional zones;
> we can specify pzones in a zonelist for __alloc_pages() and the vmscan
> code works on pzones with few modifications.
> 
> Signed-off-by: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
> 
> ---
>  include/linux/gfp.h    |    3 
>  include/linux/mm.h     |   49 ++
>  include/linux/mmzone.h |  118 ++++++
>  include/linux/swap.h   |    2 
>  mm/Kconfig             |    6 
>  mm/page_alloc.c        |  845 +++++++++++++++++++++++++++++++++++++++++++++----
>  mm/shmem.c             |    2 
>  mm/vmscan.c            |   75 +++-
>  8 files changed, 1020 insertions(+), 80 deletions(-)
Could you divide this *large* patch to several pieces ?

It looks you don't want to use functions based on zones, buddy-system, lru-list etc..
I think what you want is just a hierarchical memory allocator.
Why do you modify zone and make codes complicated ?
Can your memory allocater be implimented like mempool or hugetlb ?
They are not so invasive.

Bye,
-- Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
