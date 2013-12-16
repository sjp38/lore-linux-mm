Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id E28E16B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 12:37:03 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id k19so4275223igc.2
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:37:03 -0800 (PST)
Date: Mon, 16 Dec 2013 11:37:08 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [RFC PATCH 3/3] Change THP behavior
Message-ID: <20131216173708.GB15663@sgi.com>
References: <cover.1386790423.git.athorlton@sgi.com>
 <20131212180057.GD134240@sgi.com>
 <20131213131349.D8DE9E0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131213131349.D8DE9E0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org

> Hm. I think this part is not correct: you collapse temp thp page
> into real one only for current procees. What will happen if a process with
> temp thp pages was forked?

That's a scenario that I hadn't yet addressed, but definitely something
I'll consider going forward.  I think we can come up with a way to
appropriately handle that situation.

> And I don't think this problem is an easy one. khugepaged can't collapse
> pages with page->_count != 1 for the same reason: to make it properly you
> need to take mmap_sem for all processes and collapse all pages at once.
> And if a page is pinned, we also can't collapse.

Again, a few things here that I hadn't taken into account.  I'll look
for a way to address these concerns.

> Sorry, I don't think the whole idea has much potential. :(

I understand that there are some issues with this initial pass at the
idea, but I think we can get things corrected and come up with a
workable solution here.  When it comes down to it, there are relatively
few options to correct the issue that I'm focusing on here, and this one
seems to be the most appropriate one that we've tried so far.  We've
looked at disabling THP on a per-cpuset/per-process basis, and that has
been met with fairly strong resistance, for good reason.  I'll take
another pass at this and hopefully be able to address some of your
concerns with the idea.

Thanks for taking the time to look the patch over!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
