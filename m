Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id F3EEB9003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:03:16 -0400 (EDT)
Received: by iehx8 with SMTP id x8so98346556ieh.3
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:03:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j1si14187099igx.6.2015.07.22.15.03.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 15:03:16 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:03:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 00/10] hugetlbfs: add fallocate support
Message-Id: <20150722150314.8c68d1715641c5533220f092@linux-foundation.org>
In-Reply-To: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>

On Tue, 21 Jul 2015 11:09:34 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Changes in this revision address the minor comment and function name
> issues brought up by Naoya Horiguchi.  Patch set is also rebased on
> current "mmotm/since-4.1".  This revision does not introduce any
> functional changes.
> 
> As suggested during the RFC process, tests have been proposed to
> libhugetlbfs as described at:
> http://librelist.com/browser//libhugetlbfs/2015/6/25/patch-tests-add-tests-for-fallocate-system-call/
> fallocate(2) man page modifications are also necessary to specify
> that fallocate for hugetlbfs only operates on whole pages.  This
> change will be submitted once the code has stabilized and been
> proposed for merging.
> 
> hugetlbfs is used today by applications that want a high degree of
> control over huge page usage.  Often, large hugetlbfs files are used
> to map a large number huge pages into the application processes.
> The applications know when page ranges within these large files will
> no longer be used, and ideally would like to release them back to
> the subpool or global pools for other uses.  The fallocate() system
> call provides an interface for preallocation and hole punching within
> files.  This patch set adds fallocate functionality to hugetlbfs.
> 
> v4:
>   Renamed vma_abort_reservation() to vma_end_reservation().
>
> ...
>
> v3 patch series:
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

eek.  Please don't hide the reviews and acks in [0/n] like this.  I
don't expect to see them there, which causes me to park the patch
series until I'm feeling awake enough to undertake the patchset's first
ever review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
