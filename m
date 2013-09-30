Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0126B0037
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 06:03:01 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so5714984pab.27
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 03:03:00 -0700 (PDT)
Date: Mon, 30 Sep 2013 11:02:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Message-ID: <20130930100249.GB2425@suse.de>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 24, 2013 at 04:37:40PM -0700, Andrew Morton wrote:
> On Mon, 23 Sep 2013 15:05:28 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > It brings thp support for ramfs, but without mmap() -- it will be posted
> > separately.
> 
> We were never going to do this :(
> 
> Has anyone reviewed these patches much yet?
> 

I am afraid I never looked too closely once I learned that the primary
motivation for this was relieving iTLB pressure in a very specific
case. AFAIK, this is not a problem in the vast majority of modern CPUs
and I found it very hard to be motivated to review the series as a result.
I suspected that in many cases that the cost of IO would continue to dominate
performance instead of TLB pressure. I also found it unlikely that there
was a workload that was tmpfs based that used enough memory to be hurt
by TLB pressure. My feedback was that a much more compelling case for the
series was needed but this discussion all happened on IRC unfortunately.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
