Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 51E0A6B0089
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 05:15:45 -0400 (EDT)
Message-ID: <520B4A76.8050903@huawei.com>
Date: Wed, 14 Aug 2013 17:14:30 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
References: <520B0B75.4030708@huawei.com> <20130814085711.GK2296@suse.de>
In-Reply-To: <20130814085711.GK2296@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Minchan Kim <minchan@kernel.org>, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 2013/8/14 16:57, Mel Gorman wrote:

> On Wed, Aug 14, 2013 at 12:45:41PM +0800, Xishi Qiu wrote:
>> A large free page buddy block will continue many times, so if the page 
>> is free, skip the whole page buddy block instead of one page.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> 
> page_order cannot be used unless zone->lock is held which is not held in
> this path. Acquiring the lock would prevent parallel allocations from the
> buddy allocator (per-cpu allocator would be ok except for refills).  I expect
> it would not be a good tradeoff to acquire the lock just to use page_order.
> 
> Nak.
> 

Oh, you are right, we must hold zone->lock first.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
