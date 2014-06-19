Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id DCF956B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 04:31:37 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so1725081iec.17
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 01:31:37 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id h5si2741132igg.14.2014.06.19.01.31.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 01:31:37 -0700 (PDT)
Received: by mail-ig0-f172.google.com with SMTP id hn18so3169201igb.11
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 01:31:37 -0700 (PDT)
Date: Thu, 19 Jun 2014 01:31:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mem-hotplug: replace simple_strtoul() with
 kstrtoul()
In-Reply-To: <53A2962B.9070904@huawei.com>
Message-ID: <alpine.DEB.2.02.1406190128190.13670@chino.kir.corp.google.com>
References: <1403151749-14013-1-git-send-email-zhenzhang.zhang@huawei.com> <53A2962B.9070904@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: nfont@austin.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, 19 Jun 2014, Zhang Zhen wrote:

> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 89f752d..c1b118a 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -406,7 +406,9 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
>  	int i, ret;
>  	unsigned long pages_per_block = PAGES_PER_SECTION * sections_per_block;
> 
> -	phys_addr = simple_strtoull(buf, NULL, 0);
> +	ret = kstrtoull(buf, 0, phys_addr);
> +	if (ret)
> +		return -EINVAL;
> 
>  	if (phys_addr & ((pages_per_block << PAGE_SHIFT) - 1))
>  		return -EINVAL;

Three issues:

 - this isn't compile tested, one of your parameters to kstrtoull() has 
   the wrong type,

 - this disregards the error returned by kstrtoull() and returns -EINVAL 
   for all possible errors, kstrtoull() returns other errors as well, and

 - the patch title in the subject line refers to simple_strtoul() and
   kstrtoul() which do not appear in your patch.

Please fix issues and resubmit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
