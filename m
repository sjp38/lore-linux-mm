Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id B8D8A6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 16:38:21 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id u57so1078852wes.9
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 13:38:20 -0800 (PST)
Message-ID: <52AA2C87.5040509@redhat.com>
Date: Thu, 12 Dec 2013 16:37:11 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/3] Add tunable to control THP behavior
References: <cover.1386790423.git.athorlton@sgi.com> <20131212180050.GC134240@sgi.com>
In-Reply-To: <20131212180050.GC134240@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On 12/12/2013 01:00 PM, Alex Thorlton wrote:
> This part of the patch adds a tunable to
> /sys/kernel/mm/transparent_hugepage called threshold.  This threshold
> determines how many pages a user must fault in from a single node before
> a temporary compound page is turned into a THP.

> +++ b/mm/huge_memory.c
> @@ -44,6 +44,9 @@ unsigned long transparent_hugepage_flags __read_mostly =
>   	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
>   	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
>
> +/* default to 1 page threshold for handing out thps; maintains old behavior */
> +static int transparent_hugepage_threshold = 1;

I assume the motivation for writing all this code is that "1"
was not a good value in your tests.

That makes me wonder, why should 1 be the default value with
your patches?

If there is a better value, why should we not use that?

What is the upside of using a better value?

What is the downside?

Is there a value that would to bound the downside, so it
is almost always smaller than the upside?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
