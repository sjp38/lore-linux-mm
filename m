Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 769276B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 20:18:45 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Sep 2013 05:48:42 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id E57D61258051
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 05:48:46 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8H0Km7634668714
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 05:50:49 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8H0IcEm009855
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 05:48:39 +0530
Date: Tue, 17 Sep 2013 08:18:37 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v5 3/4] mm/vmalloc: revert "mm/vmalloc.c: check
 VM_UNINITIALIZED flag in s_show instead of show_numa_info"
Message-ID: <20130917001837.GA9692@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1379202342-23140-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <523776D4.4070402@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <523776D4.4070402@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi KOSAKI,
On Mon, Sep 16, 2013 at 05:23:32PM -0400, KOSAKI Motohiro wrote:
>On 9/14/2013 7:45 PM, Wanpeng Li wrote:
>> Changelog:
>>  *v2 -> v3: revert commit d157a558 directly
>> 
>> The VM_UNINITIALIZED/VM_UNLIST flag introduced by commit f5252e00(mm: avoid
>> null pointer access in vm_struct via /proc/vmallocinfo) is used to avoid
>> accessing the pages field with unallocated page when show_numa_info() is
>> called. This patch move the check just before show_numa_info in order that
>> some messages still can be dumped via /proc/vmallocinfo. This patch revert 
>> commit d157a558 (mm/vmalloc.c: check VM_UNINITIALIZED flag in s_show instead 
>> of show_numa_info);
>
>Both d157a558 and your patch don't explain why your one is better. Yes, some
>messages _can_ be dumped. But why should we do so?

More messages can be dumped and original commit f5252e00(mm: avoid null pointer 
access in vm_struct via /proc/vmallocinfo) do that. 

>
>And No. __get_vm_area_node() doesn't use __GFP_ZERO for allocating vm_area_struct.
>dumped partial dump is not only partial, but also may be garbage.

vm_struct is allocated by kzalloc_node.

>
>I wonder why we need to call setup_vmalloc_vm() _after_ insert_vmap_area.

I think it's another topic. 

Fill vm_struct and set VM_VM_AREA flag. If I misunderstand your
question?

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
