From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] mm/hugetlb: use already exist interface
 huge_page_shift
Date: Thu, 23 May 2013 07:40:19 +0800
Message-ID: <49114.4484411508$1369266035@news.gmane.org>
References: <1369214970-1526-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1369214970-1526-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130522105246.GF19989@dhcp22.suse.cz>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UfIdw-0005QJ-El
	for glkm-linux-mm-2@m.gmane.org; Thu, 23 May 2013 01:40:28 +0200
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id B0B166B0002
	for <linux-mm@kvack.org>; Wed, 22 May 2013 19:40:26 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 23 May 2013 20:37:45 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 8F0C92CE8051
	for <linux-mm@kvack.org>; Thu, 23 May 2013 09:40:22 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4MNQ4QD21954702
	for <linux-mm@kvack.org>; Thu, 23 May 2013 09:26:04 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4MNeKZY005582
	for <linux-mm@kvack.org>; Thu, 23 May 2013 09:40:21 +1000
Content-Disposition: inline
In-Reply-To: <20130522105246.GF19989@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 22, 2013 at 12:52:46PM +0200, Michal Hocko wrote:
>On Wed 22-05-13 17:29:30, Wanpeng Li wrote:
>> Use already exist interface huge_page_shift instead of h->order + PAGE_SHIFT.
>
>alloc_bootmem_huge_page in powerpc uses the same construct so maybe you
>want to udpate that one as well.
>

I will add this, thanks Michal, ;-) 

>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
>> ---
>>  mm/hugetlb.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index f8feeec..b6ff0ee 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -319,7 +319,7 @@ unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
>>  
>>  	hstate = hstate_vma(vma);
>>  
>> -	return 1UL << (hstate->order + PAGE_SHIFT);
>> +	return 1UL << huge_page_shift(hstate);
>>  }
>>  EXPORT_SYMBOL_GPL(vma_kernel_pagesize);
>>  
>> -- 
>> 1.8.1.2
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
