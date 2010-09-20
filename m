Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4A26B004A
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 07:15:49 -0400 (EDT)
Message-ID: <215a2d3717d0d55026688fb59ff7bb79.squirrel@www.firstfloor.org>
In-Reply-To: <20100920110323.GI1998@csn.ul.ie>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
    <1283908781-13810-4-git-send-email-n-horiguchi@ah.jp.nec.com>
    <20100920110323.GI1998@csn.ul.ie>
Date: Mon, 20 Sep 2010 13:15:44 +0200
Subject: Re: [PATCH 03/10] hugetlb: redefine hugepage copy functions
From: "Andi Kleen" <andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


>> +static void copy_gigantic_page(struct page *dst, struct page *src)
>> +{
>> +	int i;
>> +	struct hstate *h = page_hstate(src);
>> +	struct page *dst_base = dst;
>> +	struct page *src_base = src;
>> +
>> +	for (i = 0; i < pages_per_huge_page(h); ) {
>> +		cond_resched();
>
> Should this function not have a might_sleep() check too?

cond_resched() implies might_sleep I believe. I think
that answers the earlier question too becuse that function
calls this.

	/*
>
> Other than the removal of the might_sleep() check, this looks ok too.

Can I assume an Ack?

Thanks,
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
