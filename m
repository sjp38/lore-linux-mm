Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 549958D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 04:01:45 -0500 (EST)
Date: Wed, 23 Feb 2011 09:01:14 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v2] hugetlbfs: correct handling of negative input to
	/proc/sys/vm/nr_hugepages
Message-ID: <20110223090113.GI15652@csn.ul.ie>
References: <4D6419C0.8080804@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4D6419C0.8080804@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Tue, Feb 22, 2011 at 09:17:04PM +0100, Petr Holasek wrote:
> When user insert negative value into /proc/sys/vm/nr_hugepages it will  
> result
> in the setting a random number of HugePages in system (can be easily showed
> at /proc/meminfo output). This patch fixes the wrong behavior so that the
> negative input will result in nr_hugepages value unchanged.
>
> v2: same fix was also done in hugetlb_overcommit_handler function
>     as suggested by reviewers.
>
> Signed-off-by: Petr Holasek <pholasek@redhat.com>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
