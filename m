Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f48.google.com (mail-oa0-f48.google.com [209.85.219.48])
	by kanga.kvack.org (Postfix) with ESMTP id B63B96B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 20:01:56 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id m6so1387186oag.21
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 17:01:56 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 24 Sep 2013 10:01:50 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 583BA2BB0056
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 10:01:48 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8O01bA11311182
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 10:01:37 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8O01ltr000710
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 10:01:48 +1000
Date: Tue, 24 Sep 2013 08:01:46 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v5 1/4] mm/vmalloc: don't set area->caller twice
Message-ID: <5240d674.e1c1440a.315b.03d2SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <5237617F.6010107@jp.fujitsu.com>
 <5237946f.4815440a.094e.ffff8c29SMTPIN_ADDED_BROKEN@mx.google.com>
 <20130923161805.4b4b570241224b673e5c3b1b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130923161805.4b4b570241224b673e5c3b1b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi KOSAKI, any comments to patch 2/4,3/4? or you are Ack?
On Mon, Sep 23, 2013 at 04:18:05PM -0700, Andrew Morton wrote:
>On Tue, 17 Sep 2013 07:29:41 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>
>> >> to set it again in __vmalloc_area_node.
>> >> 
>> >> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>> >> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> >> ---
>> >>  mm/vmalloc.c | 1 -
>> >>  1 file changed, 1 deletion(-)
>> >> 
>> >> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> >> index 1074543..d78d117 100644
>> >> --- a/mm/vmalloc.c
>> >> +++ b/mm/vmalloc.c
>> >> @@ -1566,7 +1566,6 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>> >>  		pages = kmalloc_node(array_size, nested_gfp, node);
>> >>  	}
>> >>  	area->pages = pages;
>> >> -	area->caller = caller;
>> >>  	if (!area->pages) {
>> >>  		remove_vm_area(area->addr);
>> >>  		kfree(area);
>> >
>> >Then, __vmalloc_area_node() no longer need "caller" argument. It can use area->caller instead.
>> >
>> 
>> Thanks for pointing out, I will update it in next version. 
>
>I've seen so many versions of this patchset that my head has spun right
>off.  I'm not at all confident that I have the latest version and I'm
>certainly not confident that I've kept up with the ack/nack trail.
>
>So I think I'll drop everything and will await that "next version". 
>Please be careful to Cc everyone who was involved and that the
>acked/reviewed-by paperwork is up to date.
>
>Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
