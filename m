Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2606B004D
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 04:57:16 -0500 (EST)
Received: by iaqq3 with SMTP id q3so3054253iaq.14
        for <linux-mm@kvack.org>; Thu, 01 Dec 2011 01:57:14 -0800 (PST)
Subject: Re: [PATCH] mm: incorrect overflow check in shrink_slab()
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Xi Wang <xi.wang@gmail.com>
In-Reply-To: <20111201183202.2e5bd872.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 1 Dec 2011 04:57:10 -0500
Content-Transfer-Encoding: 7bit
Message-Id: <C71EB769-AD4F-4860-BC1D-0BEC268894AC@gmail.com>
References: <0D9D9F79-204D-4460-8CE7-A583C5C38A1E@gmail.com> <20111201183202.2e5bd872.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Dec 1, 2011, at 4:32 AM, KAMEZAWA Hiroyuki wrote:
> Nice catch but.... the 'total_scan" shouldn't be long ?
> Rather than type casting ?

Could be..  I am just trying to avoid signed integer overflow like
"total_scan += delta" in that case, which is undefined, even though
the kernel is compiled with -fno-strict-overflow.

- xi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
