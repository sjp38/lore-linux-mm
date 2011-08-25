Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 366D36B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 06:22:14 -0400 (EDT)
Message-ID: <4E562248.2090102@redhat.com>
Date: Thu, 25 Aug 2011 18:22:00 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] numa: introduce CONFIG_NUMA_SYSFS for drivers/base/node.c
References: <20110804145834.3b1d92a9eeb8357deb84bf83@canb.auug.org.au> <20110804152211.ea10e3e7.rdunlap@xenotime.net> <20110823143912.0691d442.akpm@linux-foundation.org> <4E547155.8090709@redhat.com> <20110824191430.8a908e70.rdunlap@xenotime.net> <4E55C221.8080100@redhat.com> <20110824205044.7ff45b6c.rdunlap@xenotime.net> <alpine.DEB.2.00.1108242202050.576@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1108242202050.576@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, gregkh@suse.de, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

ao? 2011a1'08ae??25ae?JPY 13:04, David Rientjes a??e??:
> On Wed, 24 Aug 2011, Randy Dunlap wrote:
>
>>> Below is the updated version.
>>>
>>> Thanks for testing!
>>
>> Yes, that works after changing #ifdef defined(...)
>> to #if defined(...)
>>
>> Acked-by: Randy Dunlap<rdunlap@xenotime.net>
>>
>
> No, it doesn't work, CONFIG_HUGETLBFS can be enabled with CONFIG_NUMA=y
> and CONFIG_SYSFS=n and that uses data structures from drivers/base/node.c
> which doesn't get compiled with this patch.

So, you mean with CONFIG_NUMA=y && CONFIG_SYSFS=n && CONFIG_HUGETLBFS=y
we still get compile error?

Which data structures are used by hugetlbfs?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
