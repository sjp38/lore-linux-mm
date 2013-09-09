Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 17BCD6B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 02:55:17 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MSU005NCJ5WX220@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 09 Sep 2013 07:55:15 +0100 (BST)
Content-transfer-encoding: 8BIT
Message-id: <1378709713.29327.0.camel@AMDC1943>
Subject: Re: [RFC PATCH 0/4] mm: migrate zbud pages
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Mon, 09 Sep 2013 08:55:13 +0200
In-reply-to: <20130906173027.GA3741@variantweb.net>
References: <1377852176-30970-1-git-send-email-k.kozlowski@samsung.com>
 <20130906173027.GA3741@variantweb.net>
References: <1377852176-30970-1-git-send-email-k.kozlowski@samsung.com>
 <20130906173027.GA3741@variantweb.net>
In-reply-to: <20130906173027.GA3741@variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On piA?, 2013-09-06 at 12:30 -0500, Seth Jennings wrote:
> On Fri, Aug 30, 2013 at 10:42:52AM +0200, Krzysztof Kozlowski wrote:
> > Hi,
> > 
> > Currently zbud pages are not movable and they cannot be allocated from CMA
> > region. These patches add migration of zbud pages.
> 
> Hey Krzysztof,
> 
> Thanks for the patches.  I haven't had time to look at them yet but wanted to
> let you know that I plan to early next week.
> 
> Seth

Great, thanks! Patches rebase and builds cleanly on current
mainline (v3.11-7890-ge5c832d).


Best regards,
Krzysztof


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
