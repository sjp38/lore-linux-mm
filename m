Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 247006B0103
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 03:56:29 -0500 (EST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MHQ00MMAOO5RW30@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 05 Feb 2013 08:56:27 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync1.samsung.com (Oracle Communications Messaging Server 7u4-23.01
 (7.0.4.23.0) 64bit (built Aug 10 2011))
 with ESMTPA id <0MHQ008TJOTYXK20@eusync1.samsung.com> for linux-mm@kvack.org;
 Tue, 05 Feb 2013 08:56:27 +0000 (GMT)
Message-id: <5110C935.6020308@samsung.com>
Date: Tue, 05 Feb 2013 09:56:21 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: cma: fix accounting of CMA pages placed in high memory
References: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
 <20130204150657.6d05f76a.akpm@linux-foundation.org>
 <CAH9JG2Usd4HJKrBXwX3aEc3i6068zU=F=RjcoQ8E8uxYGrwXgg@mail.gmail.com>
 <20130205082822.GE21389@suse.de>
In-reply-to: <20130205082822.GE21389@suse.de>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Kyungmin Park <kmpark@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan@kernel.org

Hello,

On 2/5/2013 9:28 AM, Mel Gorman wrote:
> On Tue, Feb 05, 2013 at 08:29:26AM +0900, Kyungmin Park wrote:
> > >
> > > (This information is needed so that others can make patch-scheduling
> > > decisions and should be included in all bugfix changelogs unless it is
> > > obvious).
> >
> > CMA Highmem support is new feature. so don't need to go stable tree.
> >
>
> You could have given a lot more information to that question!
>
> How new a feature is it?

ARM DMA-mapping, the only in-kernel client of CMA, will gain himem 
support in
v3.9. On the other hand, there might be out of tree clients of
alloc_contig_migrate_range()/dma_alloc_from_contiguous() API. If you think
we should care about them, then this patch might need to be backported
to stable kernels.

>   Does this mean that this patch must go in before
> 3.8 releases or is it a fix against a patch that is only in Andrew's tree?
> If the patch is only in Andrew's tree, which one is it and should this be
> folded in as a fix?
>
> On a semi-related note; is there a plan for backporting highmem support for
> the LTSI kernel considering it's aimed at embedded and CMA was highlighted
> in their announcment for 3.4 support?

I've just noticed recently that LTSI released v3.4 kernel with CMA support.
I've checked that code only briefly and noticed that it didn't have all the
CMA related patches which are available in v3.8-rc1. I will take a look at
that code and maybe I will find some time to backport some more patches from
mainline, but please note that mainline kernel has higher priority.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
