Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB295qsQ015667
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Dec 2008 18:05:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 628EB45DE52
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 18:05:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 42E9E45DE4F
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 18:05:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 19B701DB8040
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 18:05:52 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B9B4B1DB803E
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 18:05:51 +0900 (JST)
Date: Tue, 2 Dec 2008 18:05:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 10/11] memcg: show inactive_ratio
Message-Id: <20081202180502.10ad4b42.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081201211817.1CE8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081201211817.1CE8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon,  1 Dec 2008 21:19:08 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> add inactive_ratio field to memory.stat file.
> it is useful for memcg reclam debugging.
> 
Hmm...it seems no requirement for showing this in usual use.
I'll put this under CONFIG_DEBUG_VM.

Thanks,
-Kame

> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> Index: b/mm/memcontrol.c
> ===================================================================
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1796,6 +1796,9 @@ static int mem_control_stat_show(struct 
>  		cb->fill(cb, "unevictable", unevictable * PAGE_SIZE);
>  
>  	}
> +
> +	cb->fill(cb, "inactive_ratio", mem_cont->inactive_ratio);
> +
>  	return 0;
>  }
>  
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
