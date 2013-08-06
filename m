Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 5D95D6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 09:05:18 -0400 (EDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MR4002G31NX1190@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 06 Aug 2013 14:05:16 +0100 (BST)
Message-id: <1375794314.13955.6.camel@AMDC1943>
Subject: Re: [RFC PATCH 0/4] mm: reclaim zbud pages on migration and compaction
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Tue, 06 Aug 2013 15:05:14 +0200
In-reply-to: <5200BEEF.7060904@oracle.com>
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
 <5200BEEF.7060904@oracle.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On wto, 2013-08-06 at 17:16 +0800, Bob Liu wrote:
> On 08/06/2013 02:42 PM, Krzysztof Kozlowski wrote:
> > This reclaim process is different than zbud_reclaim_page(). It acts more
> > like swapoff() by trying to unuse pages stored in zbud page and bring
> > them back to memory. The standard zbud_reclaim_page() on the other hand
> > tries to write them back.
> 
> I prefer to migrate zbud pages directly if it's possible than reclaiming
> them during compaction.

I think it is possible however it would be definitely more complex. In
case of migration the zswap handles should be updated as they are just
virtual addresses. Am I right?

Best regards,
Krzysztof


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
