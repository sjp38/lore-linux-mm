Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 919606B00EF
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 01:09:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D590E0014972
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Oct 2010 14:09:00 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B7AF45DE4E
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:09:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EDB2045DE4D
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:08:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CE3461DB803E
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:08:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BC911DB8038
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:08:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] fix return value of scan_lru_pages in memory unplug
In-Reply-To: <20101013135903.c505ff8b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101013135903.c505ff8b.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20101013140841.ADBA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Oct 2010 14:08:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

> CC'ed to stable tree...maybe all kernel has this bug.
> But this may not very critical because we've got no report until now.

Thanks.


> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> scan_lru_pages returns pfn. So, it's type should be "unsigned long"
> not "int".
> 
> Note: I guess this has been work until now because memory hotplug tester's
>       machine has not very big memory....
>       physical address < 32bit << PAGE_SHIFT.
> 
> Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memory_hotplug.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: mmotm-1008/mm/memory_hotplug.c
> ===================================================================
> --- mmotm-1008.orig/mm/memory_hotplug.c
> +++ mmotm-1008/mm/memory_hotplug.c
> @@ -646,7 +646,7 @@ static int test_pages_in_a_zone(unsigned
>   * Scanning pfn is much easier than scanning lru list.
>   * Scan pfn from start to end and Find LRU page.
>   */
> -int scan_lru_pages(unsigned long start, unsigned long end)
> +unsigned long scan_lru_pages(unsigned long start, unsigned long end)

Also, this can be static. anyway
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
