Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id E53DE6B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 16:38:50 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id i17so1539088qcy.0
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 13:38:50 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id b7si6735834qad.142.2014.03.03.13.38.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 13:38:50 -0800 (PST)
Message-ID: <5314F661.30202@oracle.com>
Date: Mon, 03 Mar 2014 16:38:41 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add pte_present() check on existing hugetlb_entry
 callbacks
References: <53126861.7040107@oracle.com> <1393822946-26871-1-git-send-email-n-horiguchi@ah.jp.nec.com> <5314E0CD.6070308@oracle.com>
In-Reply-To: <5314E0CD.6070308@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On 03/03/2014 03:06 PM, Sasha Levin wrote:
> On 03/03/2014 12:02 AM, Naoya Horiguchi wrote:
>> Hi Sasha,
>>
>>> >I can confirm that with this patch the lockdep issue is gone. However, the NULL deref in
>>> >walk_pte_range() and the BUG at mm/hugemem.c:3580 still appear.
>> I spotted the cause of this problem.
>> Could you try testing if this patch fixes it?
>
> I'm seeing a different failure with this patch:

And the NULL deref still happens.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
