Date: Thu, 07 Aug 2008 20:00:37 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Race condition between putback_lru_page and mem_cgroup_move_list
In-Reply-To: <1218041585.6173.45.camel@lts-notebook>
References: <489741F8.2080104@linux.vnet.ibm.com> <1218041585.6173.45.camel@lts-notebook>
Message-Id: <20080807185203.A8C2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, MinChan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi

> If you mean the "active/inactive list transition" in
> shrink_[in]active_list(), these are already batched under zone lru_lock
> with batch size determined by the 'release pages' pvec.  So, I think
> we're OK here.

No.

AFAIK shrink_inactive_list batched zone->lru_lock, 
but it doesn't batched mz->lru_lock.

then, spin_lock_irqsave is freqently called.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
