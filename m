Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 517739003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:20:14 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so192817704wib.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:20:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bp4si4851259wjb.14.2015.07.22.15.20.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 15:20:12 -0700 (PDT)
Message-ID: <1437603594.3298.5.camel@stgolabs.net>
Subject: Re: [PATCH v4 00/10] hugetlbfs: add fallocate support
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 22 Jul 2015 15:19:54 -0700
In-Reply-To: <20150722150647.2597c7e5be9ee1eecc438b6f@linux-foundation.org>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
	 <20150722150647.2597c7e5be9ee1eecc438b6f@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 2015-07-22 at 15:06 -0700, Andrew Morton wrote:
> On Tue, 21 Jul 2015 11:09:34 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
> > As suggested during the RFC process, tests have been proposed to
> > libhugetlbfs as described at:
> > http://librelist.com/browser//libhugetlbfs/2015/6/25/patch-tests-add-tests-for-fallocate-system-call/

Great!

> 
> I didn't know that libhugetlbfs has tests.  I wonder if that makes
> tools/testing/selftests/vm's hugetlbfstest harmful?

Why harmful? Redundant, maybe(?). Does anyone even use selftests for
hugetlbfs regression testing? Lets see, we also have these:

- hugepage-{mmap,shm}.c
- map_hugetlb.c

There's probably a lot of room for improvement here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
