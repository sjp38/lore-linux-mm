Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 43D6A9003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:30:25 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so178223603ieb.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:30:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lq5si3232557igb.63.2015.07.22.15.30.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 15:30:24 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:30:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 00/10] hugetlbfs: add fallocate support
Message-Id: <20150722153023.e8f15eb4e490f79cc029c8cd@linux-foundation.org>
In-Reply-To: <1437603594.3298.5.camel@stgolabs.net>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
	<20150722150647.2597c7e5be9ee1eecc438b6f@linux-foundation.org>
	<1437603594.3298.5.camel@stgolabs.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 22 Jul 2015 15:19:54 -0700 Davidlohr Bueso <dave@stgolabs.net> wrote:

> > 
> > I didn't know that libhugetlbfs has tests.  I wonder if that makes
> > tools/testing/selftests/vm's hugetlbfstest harmful?
> 
> Why harmful? Redundant, maybe(?).

The presence of the in-kernel tests will cause people to add stuff to
them when it would be better if they were to apply that effort to
making libhugetlbfs better.  Or vice versa.

Mike's work is an example.  Someone later makes a change to hugetlbfs, runs
the kernel selftest and says "yay, everything works", unaware that they
just broke fallocate support.

> Does anyone even use selftests for
> hugetlbfs regression testing? Lets see, we also have these:
> 
> - hugepage-{mmap,shm}.c
> - map_hugetlb.c
> 
> There's probably a lot of room for improvement here.

selftests is a pretty scrappy place.  It's partly a dumping ground for
things so useful test code doesn't just get lost and bitrotted.  Partly
a framework so people who add features can easily test them. Partly to
provide tools to architecture maintainers when they wire up new
syscalls and the like.

Unless there's some good reason to retain the hugetlb part of
selftests, I'm thinking we should just remove it to avoid
distracting/misleading people.  Or possibly move the libhugetlbfs test
code into the kernel tree and maintain it there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
