Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id B35F86B003B
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:56:20 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so8354302pbb.37
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 11:56:20 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id yd9si11323384pab.118.2013.12.10.11.56.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 11:56:19 -0800 (PST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 87E723EE0B6
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:56:17 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 792BE45DEBE
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:56:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C27245DEB7
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:56:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BF17E08003
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:56:17 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 009D11DB803C
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:56:17 +0900 (JST)
Message-ID: <52A771EC.4080105@jp.fujitsu.com>
Date: Tue, 10 Dec 2013 14:56:28 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] mm: add show num_poisoned_pages when oom
References: <52A670AC.6090504@huawei.com>
In-Reply-To: <52A670AC.6090504@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qiuxishi@huawei.com, akpm@linux-foundation.org, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, n-horiguchi@ah.jp.nec.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(12/9/2013 8:38 PM), Xishi Qiu wrote:
> Show num_poisoned_pages when oom, it is a little helpful to find the reason.
> Also it will be emitted anytime show_mem() is called.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
> ---
>  lib/show_mem.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/lib/show_mem.c b/lib/show_mem.c
> index 5847a49..1cbdcd8 100644
> --- a/lib/show_mem.c
> +++ b/lib/show_mem.c
> @@ -46,4 +46,7 @@ void show_mem(unsigned int filter)
>  	printk("%lu pages in pagetable cache\n",
>  		quicklist_total_size());
>  #endif
> +#ifdef CONFIG_MEMORY_FAILURE
> +	printk("%lu pages hwpoisoned\n", atomic_long_read(&num_poisoned_pages));
> +#endif
>  }

Looks ok.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
