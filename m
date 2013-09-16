Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D77D26B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 19:29:46 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Sep 2013 09:29:44 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 2C66D2BB0054
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:29:43 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8GNDDKS5177602
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:13:13 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8GNTg7w004956
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:29:42 +1000
Date: Tue, 17 Sep 2013 07:29:41 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v5 1/4] mm/vmalloc: don't set area->caller twice
Message-ID: <20130916232941.GC3241@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <5237617F.6010107@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5237617F.6010107@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi KOSAKI,
On Mon, Sep 16, 2013 at 03:52:31PM -0400, KOSAKI Motohiro wrote:
>On 9/14/2013 7:45 PM, Wanpeng Li wrote:
>> Changelog:
>>  *v1 -> v2: rebase against mmotm tree
>> 
>> The caller address has already been set in set_vmalloc_vm(), there's no need
>
>                                            setup_vmalloc_vm()
>

Thanks.

>> to set it again in __vmalloc_area_node.
>> 
>> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/vmalloc.c | 1 -
>>  1 file changed, 1 deletion(-)
>> 
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 1074543..d78d117 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1566,7 +1566,6 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>>  		pages = kmalloc_node(array_size, nested_gfp, node);
>>  	}
>>  	area->pages = pages;
>> -	area->caller = caller;
>>  	if (!area->pages) {
>>  		remove_vm_area(area->addr);
>>  		kfree(area);
>
>Then, __vmalloc_area_node() no longer need "caller" argument. It can use area->caller instead.
>

Thanks for pointing out, I will update it in next version. 

Regards,
Wanpeng Li 

>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
