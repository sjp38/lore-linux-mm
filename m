Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1F06B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 19:18:09 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so4165904pab.36
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 16:18:08 -0700 (PDT)
Date: Mon, 23 Sep 2013 16:18:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH v5 1/4] mm/vmalloc: don't set area->caller twice
Message-Id: <20130923161805.4b4b570241224b673e5c3b1b@linux-foundation.org>
In-Reply-To: <5237946f.4815440a.094e.ffff8c29SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<5237617F.6010107@jp.fujitsu.com>
	<5237946f.4815440a.094e.ffff8c29SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, iamjoonsoo.kim@lge.com, rientjes@google.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 17 Sep 2013 07:29:41 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:

> >> to set it again in __vmalloc_area_node.
> >> 
> >> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> >> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >> ---
> >>  mm/vmalloc.c | 1 -
> >>  1 file changed, 1 deletion(-)
> >> 
> >> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> >> index 1074543..d78d117 100644
> >> --- a/mm/vmalloc.c
> >> +++ b/mm/vmalloc.c
> >> @@ -1566,7 +1566,6 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
> >>  		pages = kmalloc_node(array_size, nested_gfp, node);
> >>  	}
> >>  	area->pages = pages;
> >> -	area->caller = caller;
> >>  	if (!area->pages) {
> >>  		remove_vm_area(area->addr);
> >>  		kfree(area);
> >
> >Then, __vmalloc_area_node() no longer need "caller" argument. It can use area->caller instead.
> >
> 
> Thanks for pointing out, I will update it in next version. 

I've seen so many versions of this patchset that my head has spun right
off.  I'm not at all confident that I have the latest version and I'm
certainly not confident that I've kept up with the ack/nack trail.

So I think I'll drop everything and will await that "next version". 
Please be careful to Cc everyone who was involved and that the
acked/reviewed-by paperwork is up to date.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
