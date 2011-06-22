Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6D3B56B01F8
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 21:24:02 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p5M1O1sL001343
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:24:01 -0700
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by wpaz9.hot.corp.google.com with ESMTP id p5M1NxOJ028927
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:24:00 -0700
Received: by pzk26 with SMTP id 26so227625pzk.38
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:23:59 -0700 (PDT)
Date: Tue, 21 Jun 2011 18:23:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] mm: improve THP printk messages
In-Reply-To: <1308643849-3325-3-git-send-email-amwang@redhat.com>
Message-ID: <alpine.DEB.2.00.1106211823310.5205@chino.kir.corp.google.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <1308643849-3325-3-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 21 Jun 2011, Amerigo Wang wrote:

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 126c96b..f9e720c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -506,7 +506,7 @@ static int __init hugepage_init(void)
>  	if (no_hugepage_init) {
>  		err = 0;
>  		transparent_hugepage_flags = 0;
> -		printk(KERN_INFO "hugepage: totally disabled\n");
> +		printk(KERN_INFO "THP: totally disabled\n");
>  		goto out;
>  	}
>  
> @@ -514,19 +514,19 @@ static int __init hugepage_init(void)
>  	err = -ENOMEM;
>  	hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
>  	if (unlikely(!hugepage_kobj)) {
> -		printk(KERN_ERR "hugepage: failed kobject create\n");
> +		printk(KERN_ERR "THP: failed kobject create\n");
>  		goto out;
>  	}
>  
>  	err = sysfs_create_group(hugepage_kobj, &hugepage_attr_group);
>  	if (err) {
> -		printk(KERN_ERR "hugepage: failed register hugeage group\n");
> +		printk(KERN_ERR "THP: failed register hugeage group\n");
>  		goto out;
>  	}
>  
>  	err = sysfs_create_group(hugepage_kobj, &khugepaged_attr_group);
>  	if (err) {
> -		printk(KERN_ERR "hugepage: failed register hugeage group\n");
> +		printk(KERN_ERR "THP: failed register hugeage group\n");
>  		goto out;
>  	}
>  #endif

You're changing a printk() but not fixing the typos in it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
