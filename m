Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 3E99B6B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 08:37:21 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so1820319vcb.14
        for <linux-mm@kvack.org>; Fri, 10 Aug 2012 05:37:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120810122730.GA1425@dhcp22.suse.cz>
References: <CAJd=RBB=jKD+9JcuBmBGC8R8pAQ-QoWHexMNMsXpb9zV548h5g@mail.gmail.com>
	<20120803133235.GA8434@dhcp22.suse.cz>
	<20120810094825.GA1440@dhcp22.suse.cz>
	<CAJd=RBDA3pLYDpryxafx6dLoy7Fk8PmY-EFkXCkuJTB2ywfsjA@mail.gmail.com>
	<20120810122730.GA1425@dhcp22.suse.cz>
Date: Fri, 10 Aug 2012 20:37:20 +0800
Message-ID: <CAJd=RBAvCd-QcyN9N4xWEiLeVqRypzCzbADvD1qTziRVCHjd4Q@mail.gmail.com>
Subject: Re: [patch] hugetlb: correct page offset index for sharing pmd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 10, 2012 at 8:27 PM, Michal Hocko <mhocko@suse.cz> wrote:
>
> I guess you mean unmap_ref_private and that has been changed by you
> (0c176d5 mm: hugetlb: fix pgoff computation when unmapping page from
> vma)...  I was wrong at that time when giving my Reviewed-by. The patch
> didn't break anything because you still find all relevant vmas because
> vma_hugecache_offset just provides a smaller index which is still within
> boundaries.

No, as shown by the log message of 0c176d52b,  that fix was
triggered by  (vma->vm_pgoff >> PAGE_SHIFT), thus I dont see
what you really want to revert.


> I think that 0c176d52 should be reverted because we do not have to refer
> to the head page in this case and as we can see it causes confusion.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
