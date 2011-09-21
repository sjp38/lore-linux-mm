Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DC9539000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 12:31:03 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8LGGKeh028681
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 12:16:20 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8LGV1rg1802242
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 12:31:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8LCUjQ2026121
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 09:30:47 -0300
Subject: Re: [PATCH 1/3] fixup! mm: alloc_contig_freed_pages() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <f57b57f83bc5980e3db7d9d42f91c7e1765b4766.1316622205.git.mina86@mina86.com>
References: <1316619959.16137.308.camel@nimitz>
	 <f57b57f83bc5980e3db7d9d42f91c7e1765b4766.1316622205.git.mina86@mina86.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 21 Sep 2011 09:30:51 -0700
Message-ID: <1316622651.16137.311.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mnazarewicz@google.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Wed, 2011-09-21 at 18:26 +0200, Michal Nazarewicz wrote:
> -               page += 1 << order;
> +
> +               if (zone_pfn_same_memmap(pfn - count, pfn))
> +                       page += count;
> +               else
> +                       page = pfn_to_page(pfn);
>         }

That all looks sane to me and should fix the bug I brought up.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
