Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 68CE96B006C
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 20:37:43 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so637448dak.28
        for <linux-mm@kvack.org>; Tue, 18 Dec 2012 17:37:42 -0800 (PST)
Date: Tue, 18 Dec 2012 17:37:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: clean up hugepage sysfs error messages
In-Reply-To: <1355880187-26709-1-git-send-email-jeder@redhat.com>
Message-ID: <alpine.DEB.2.00.1212181736530.3932@chino.kir.corp.google.com>
References: <1355880187-26709-1-git-send-email-jeder@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Eder <jeder@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Tue, 18 Dec 2012, Jeremy Eder wrote:

> This patch corrects a few typos in the hugepage sysfs init code.

Please sign off your patch.

> ---
>  mm/huge_memory.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 32754ee..0696fa4 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -574,19 +574,19 @@ static int __init hugepage_init_sysfs(struct kobject **hugepage_kobj)
>  
>  	*hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
>  	if (unlikely(!*hugepage_kobj)) {
> -		printk(KERN_ERR "hugepage: failed kobject create\n");
> +		printk(KERN_ERR "hugepage: failed to create kobject\n");

How do we know this is for thp and not hugetlbfs when it only appears in 
the kernel log?

>  		return -ENOMEM;
>  	}
>  
>  	err = sysfs_create_group(*hugepage_kobj, &hugepage_attr_group);
>  	if (err) {
> -		printk(KERN_ERR "hugepage: failed register hugeage group\n");
> +		printk(KERN_ERR "hugepage: failed to register hugepage group\n");
>  		goto delete_obj;
>  	}
>  
>  	err = sysfs_create_group(*hugepage_kobj, &khugepaged_attr_group);
>  	if (err) {
> -		printk(KERN_ERR "hugepage: failed register hugeage group\n");
> +		printk(KERN_ERR "hugepage: failed to register hugepage group\n");
>  		goto remove_hp_group;
>  	}
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
