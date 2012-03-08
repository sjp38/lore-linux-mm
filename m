Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D4FDD6B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 21:29:08 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Thu, 8 Mar 2012 03:19:36 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q282NBHh3612718
	for <linux-mm@kvack.org>; Thu, 8 Mar 2012 13:23:12 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q282SqD3026739
	for <linux-mm@kvack.org>; Thu, 8 Mar 2012 13:28:52 +1100
Message-ID: <4F581962.8040403@linux.vnet.ibm.com>
Date: Thu, 08 Mar 2012 10:28:50 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] hugetlb: drop prev_vma in hugetlb_get_unmapped_area_topdown
References: <4F101904.8090405@linux.vnet.ibm.com> <4F101935.1040108@linux.vnet.ibm.com> <20120307140101.b0624e80.akpm@linux-foundation.org>
In-Reply-To: <20120307140101.b0624e80.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 03/08/2012 06:01 AM, Andrew Morton wrote:

> On Fri, 13 Jan 2012 19:44:53 +0800
> Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com> wrote:
> 
>> Afte call find_vma_prev(mm, addr, &prev_vma), following condition is always
>> true:
>> 	!prev_vma || (addr >= prev_vma->vm_end)
>> it can be happily drop prev_vma and use find_vma instead of find_vma_prev
> 
> I had to rework this patch due to 097d59106a8e4b ("vm: avoid using
> find_vma_prev() unnecessarily") in mainline.  Can you please check my
> handiwork?
> 


It looks good to me, thanks Andrew!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
