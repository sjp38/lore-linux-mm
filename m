Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 04FE58D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 15:32:58 -0500 (EST)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p1MKWsft024268
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 12:32:54 -0800
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by kpbe15.cbf.corp.google.com with ESMTP id p1MKWq3w009274
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 12:32:53 -0800
Received: by pzk32 with SMTP id 32so410380pzk.13
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 12:32:52 -0800 (PST)
Date: Tue, 22 Feb 2011 12:32:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] hugetlbfs: correct handling of negative input to
 /proc/sys/vm/nr_hugepages
In-Reply-To: <4D6419C0.8080804@redhat.com>
Message-ID: <alpine.DEB.2.00.1102221232370.5929@chino.kir.corp.google.com>
References: <4D6419C0.8080804@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Tue, 22 Feb 2011, Petr Holasek wrote:

> When user insert negative value into /proc/sys/vm/nr_hugepages it will result
> in the setting a random number of HugePages in system (can be easily showed
> at /proc/meminfo output). This patch fixes the wrong behavior so that the
> negative input will result in nr_hugepages value unchanged.
> 
> v2: same fix was also done in hugetlb_overcommit_handler function
>     as suggested by reviewers.
> 
> Signed-off-by: Petr Holasek <pholasek@redhat.com>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
