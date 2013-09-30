Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9DAF86B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 11:28:21 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so6038517pab.31
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 08:28:21 -0700 (PDT)
Message-ID: <52499875.4060101@sr71.net>
Date: Mon, 30 Sep 2013 08:27:49 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com> <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org> <20130930100249.GB2425@suse.de>
In-Reply-To: <20130930100249.GB2425@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 09/30/2013 03:02 AM, Mel Gorman wrote:
> I am afraid I never looked too closely once I learned that the primary
> motivation for this was relieving iTLB pressure in a very specific
> case. AFAIK, this is not a problem in the vast majority of modern CPUs
> and I found it very hard to be motivated to review the series as a result.
> I suspected that in many cases that the cost of IO would continue to dominate
> performance instead of TLB pressure. I also found it unlikely that there
> was a workload that was tmpfs based that used enough memory to be hurt
> by TLB pressure. My feedback was that a much more compelling case for the
> series was needed but this discussion all happened on IRC unfortunately.

FWIW, I'm mostly intrigued by the possibilities of how this can speed up
_software_, and I'm rather uninterested in what it can do for the TLB.
Page cache is particularly painful today, precisely because hugetlbfs
and anonymous-thp aren't available there.  If you have an app with
hundreds of GB of files that it wants to mmap(), even if it's in the
page cache, it takes _minutes_ to just fault in.  One example:

	https://lkml.org/lkml/2013/6/27/698

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
