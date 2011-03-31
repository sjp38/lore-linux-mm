Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 86FF98D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 12:04:45 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2VFmrS1019946
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:48:53 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2VG4DYV097446
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:04:15 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2VG487k019469
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:04:09 -0600
Subject: Re: [PATCH 05/12] mm: alloc_contig_range() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1301577368-16095-6-git-send-email-m.szyprowski@samsung.com>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
	 <1301577368-16095-6-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 31 Mar 2011 09:04:05 -0700
Message-ID: <1301587445.31087.1042.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

On Thu, 2011-03-31 at 15:16 +0200, Marek Szyprowski wrote:
> +       _start = start & (~0UL << ret);
> +       _end   = alloc_contig_freed_pages(_start, end, flag); 

These names are a wee bit lacking.  Care to give them proper names that
might let a reader figure out how the "_" makes the variable different
from its nearly-identical twin?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
