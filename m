Date: Fri, 27 Jun 2008 14:41:00 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 8/10] fix shmem page migration incorrectness on memcgroup
In-Reply-To: <28c262360806262208i6791d67at446f7323ded16206@mail.gmail.com>
References: <20080625190750.D864.KOSAKI.MOTOHIRO@jp.fujitsu.com> <28c262360806262208i6791d67at446f7323ded16206@mail.gmail.com>
Message-Id: <20080627142950.7A83.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> > mem_cgroup_uncharge() against old page is done after radix-tree-replacement.
> > And there were special handling to ingore swap-cache page. But, shmem can
> > be swap-cache and file-cache at the same time. Chekcing PageSwapCache() is
> > not correct here. Check PageAnon() instead.
> 
> When/How shmem can be both swap-cache and file-cache ?
> I can't understand that situation.

Hi

see, 

shmem_writepage()
   -> add_to_swap_cache()
      -> SetPageSwapCache()


BTW: his file-cache mean !Anon, not mean !SwapBacked.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
