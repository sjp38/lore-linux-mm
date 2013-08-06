Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 3427E6B0034
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 05:25:36 -0400 (EDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MR3002MIRIM8N50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 06 Aug 2013 10:25:34 +0100 (BST)
Message-id: <1375781132.2003.4.camel@AMDC1943>
Subject: Re: [RFC PATCH 1/4] zbud: use page ref counter for zbud pages
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Tue, 06 Aug 2013 11:25:32 +0200
In-reply-to: <5200BB18.9010105@oracle.com>
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
 <1375771361-8388-2-git-send-email-k.kozlowski@samsung.com>
 <5200BB18.9010105@oracle.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hi Bob,

Thank you for review.

On wto, 2013-08-06 at 17:00 +0800, Bob Liu wrote:
> Nit picker, how about change the name to adjust_lists() or something
> like this because we don't do any rebalancing.

OK, I'll change it.

Best regards,
Krzysztof


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
