Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD638D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 12:02:47 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2VFhnUD011111
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:43:52 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 008066E803C
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 12:02:45 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2VG2jSA132854
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 12:02:45 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2VG2iD3025667
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 13:02:45 -0300
Subject: Re: [PATCH 05/12] mm: alloc_contig_range() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1301577368-16095-6-git-send-email-m.szyprowski@samsung.com>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
	 <1301577368-16095-6-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 31 Mar 2011 09:02:41 -0700
Message-ID: <1301587361.31087.1040.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

On Thu, 2011-03-31 at 15:16 +0200, Marek Szyprowski wrote:
> +       ret = 0;
> +       while (!PageBuddy(pfn_to_page(start & (~0UL << ret))))
> +               if (WARN_ON(++ret >= MAX_ORDER))
> +                       return -EINVAL; 

Holy cow, that's dense.  Is there really no more straightforward way to
do that?

In any case, please pull the ++ret bit out of the WARN_ON().  Some
people like to do:

#define WARN_ON(...) do{}while(0)

to save space on some systems.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
