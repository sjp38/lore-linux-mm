Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m990gX2w001768
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Oct 2008 09:42:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C89102AC026
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 09:42:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C6E112C046
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 09:42:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E57431DB803A
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 09:42:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 921A81DB8041
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 09:42:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] documentation: clarify dirty_ratio and dirty_background_ratio description
In-Reply-To: <48EC90EC.8060306@gmail.com>
References: <48EC90EC.8060306@gmail.com>
Message-Id: <20081009094134.DEB8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Oct 2008 09:42:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righi.andrea@gmail.com
Cc: kosaki.motohiro@jp.fujitsu.com, Randy Dunlap <randy.dunlap@oracle.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Rubin <mrubin@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> The current documentation of dirty_ratio and dirty_background_ratio is a
> bit misleading.
> 
> In the documentation we say that they are "a percentage of total system
> memory", but the current page writeback policy, intead, is to apply the
> percentages to the dirtyable memory, that means free pages + reclaimable
> pages.
> 
> Better to be more explicit to clarify this concept.
> 
> Signed-off-by: Andrea Righi <righi.andrea@gmail.com>

looks good to me.



> ---
>  Documentation/filesystems/proc.txt |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index f566ad9..be69c8b 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -1380,15 +1380,16 @@ causes the kernel to prefer to reclaim dentries and inodes.
>  dirty_background_ratio
>  ----------------------
>  
> -Contains, as a percentage of total system memory, the number of pages at which
> -the pdflush background writeback daemon will start writing out dirty data.
> +Contains, as a percentage of the dirtyable system memory (free pages +
> +reclaimable pages), the number of pages at which the pdflush background
> +writeback daemon will start writing out dirty data.
>  
>  dirty_ratio
>  -----------------
>  
> -Contains, as a percentage of total system memory, the number of pages at which
> -a process which is generating disk writes will itself start writing out dirty
> -data.
> +Contains, as a percentage of the dirtyable system memory (free pages +
> +reclaimable pages), the number of pages at which a process which is generating
> +disk writes will itself start writing out dirty data.
>  
>  dirty_writeback_centisecs
>  -------------------------





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
