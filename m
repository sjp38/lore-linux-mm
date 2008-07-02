Date: Wed, 02 Jul 2008 12:30:39 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH -mm] split_lru: fix pagevec_move_tail() doesn't treat unevictable page
In-Reply-To: <28c262360807011739w5668920buf7880de6ed30f912@mail.gmail.com>
References: <20080701093840.07b48ced@bree.surriel.com> <28c262360807011739w5668920buf7880de6ed30f912@mail.gmail.com>
Message-Id: <20080702122850.380B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Kim-san,

> Hi, Rik and Kosaki-san
> 
> I want to know exact race situation for remaining git log.
> As you know, git log is important for me who is newbie to understand source
> 
> There are many possibility in this race problem.
> 
> Did you use hugepage in this test ?
> I think that If you used hugepage, it seems to happen following race.

I don't use hugepage. but use SYSV-shmem.
so following scenario is very reasonable.

OK.
I resend my patch with following description.


> 
> --------------
> 
> CPU1                                                           CPU2
> 
> shm_unlock
> scan_mapping_unevictable_pages
> check_move_unevictable_page
> ClearPageUnevictable                                 rotate_reclaimable_page
> 
> PageUnevictable(page) return 0
> SetPageUnevictable
> list_move(LRU_UNEVICTABLE)
> 
> local_irq_save
> 
> pagevec_move_tail
> 
> Do you think it is possible ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
