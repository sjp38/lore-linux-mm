Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 0E2C46B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 02:10:37 -0500 (EST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Thu, 2 Feb 2012 07:03:25 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1272feZ2707570
	for <linux-mm@kvack.org>; Thu, 2 Feb 2012 18:02:44 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1277WQS003520
	for <linux-mm@kvack.org>; Thu, 2 Feb 2012 18:07:32 +1100
Message-ID: <4F2A362A.3020006@linux.vnet.ibm.com>
Date: Thu, 02 Feb 2012 15:07:22 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm: search from free_area_cache for the bigger size
References: <4F101904.8090405@linux.vnet.ibm.com> <4F1019D3.8020709@linux.vnet.ibm.com> <20120201144401.af84e3a2.akpm@linux-foundation.org>
In-Reply-To: <20120201144401.af84e3a2.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 02/02/2012 06:44 AM, Andrew Morton wrote:

> On Fri, 13 Jan 2012 19:47:31 +0800
> Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com> wrote:
> 
>> If the required size is bigger than cached_hole_size, we would better search
>> from free_area_cache, it is more easier to get free region, specifically for
>> the 64 bit process whose address space is large enough
>>
>> Do it just as hugetlb_get_unmapped_area_topdown() in arch/x86/mm/hugetlbpage.c
> 
> Can this cause additional fragmentation of the virtual address region? 
> If so, what might be the implications of this?


Hmm, i think it is not bad since we have cached_hole_size, and, this way is also
used in other functions and architectures(arch_get_unmapped_area,
hugetlb_get_unmapped_area_bottomup, hugetlb_get_unmapped_area_topdown......).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
