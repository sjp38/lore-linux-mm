Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id F1F1A6B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 09:39:22 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so1895885vcb.14
        for <linux-mm@kvack.org>; Fri, 10 Aug 2012 06:39:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBDtnF6eoTmDu4HOBGfHnWnxNsXEzArR51+-XhzFCwOmOQ@mail.gmail.com>
References: <CAJd=RBB=jKD+9JcuBmBGC8R8pAQ-QoWHexMNMsXpb9zV548h5g@mail.gmail.com>
	<20120803133235.GA8434@dhcp22.suse.cz>
	<20120810094825.GA1440@dhcp22.suse.cz>
	<CAJd=RBDA3pLYDpryxafx6dLoy7Fk8PmY-EFkXCkuJTB2ywfsjA@mail.gmail.com>
	<20120810122730.GA1425@dhcp22.suse.cz>
	<CAJd=RBAvCd-QcyN9N4xWEiLeVqRypzCzbADvD1qTziRVCHjd4Q@mail.gmail.com>
	<20120810125102.GB1425@dhcp22.suse.cz>
	<CAJd=RBB8Yuk1FEQxTUbEEeD96oqnO26VojetuDgRo=JxOfnadw@mail.gmail.com>
	<20120810131643.GC1425@dhcp22.suse.cz>
	<CAJd=RBDtnF6eoTmDu4HOBGfHnWnxNsXEzArR51+-XhzFCwOmOQ@mail.gmail.com>
Date: Fri, 10 Aug 2012 21:39:21 +0800
Message-ID: <CAJd=RBAOu9b5FRmYxbY7dKRp5G8VmOxvtgHLE7jwin1ZgqMmLw@mail.gmail.com>
Subject: Re: [patch] hugetlb: correct page offset index for sharing pmd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>

On Fri, Aug 10, 2012 at 9:21 PM, Hillf Danton <dhillf@gmail.com> wrote:
> On Fri, Aug 10, 2012 at 9:16 PM, Michal Hocko <mhocko@suse.cz> wrote:
>> Subject: [PATCH] hugetlb: do not use vma_hugecache_offset for
>>  vma_prio_tree_foreach
>>
>> 0c176d5 (mm: hugetlb: fix pgoff computation when unmapping page
>> from vma) fixed pgoff calculation but it has replaced it by
>> vma_hugecache_offset which is not approapriate for offsets used for
>> vma_prio_tree_foreach because that one expects index in page units
>> rather than in huge_page_shift.
>> Using vma_hugecache_offset is not incorrect because the pgoff will fit
>> into the same vmas but it is confusing.
>>
>
> Well, how is the patch tested?


You see, Michal, it is weekend and I have to be offline now.

See you next week ;)

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
