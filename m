Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 402116B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 20:46:25 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c21-v6so29549002ioi.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 17:46:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c135-v6si1397081ith.124.2018.10.18.17.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 17:46:24 -0700 (PDT)
Date: Thu, 18 Oct 2018 20:46:21 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] hugetlbfs: dirty pages as they are added to pagecache
Message-ID: <20181019004621.GA30067@redhat.com>
References: <20181018041022.4529-1-mike.kravetz@oracle.com>
 <20181018160827.0cb656d594ffb2f0f069326c@linux-foundation.org>
 <6d6e4733-39aa-a958-c0a2-c5a47cdcc7d0@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6d6e4733-39aa-a958-c0a2-c5a47cdcc7d0@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Alexander Viro <viro@zeniv.linux.org.uk>, stable@vger.kernel.org

On Thu, Oct 18, 2018 at 04:16:40PM -0700, Mike Kravetz wrote:
> I was not sure about this, and expected someone could come up with
> something better.  It just seems there are filesystems like huegtlbfs,
> where it makes no sense wasting cycles traversing the filesystem.  So,
> let's not even try.
> 
> Hoping someone can come up with a better method than hard coding as
> I have done above.

It's not strictly required after marking the pages dirty though. The
real fix is the other one? Could we just drop the hardcoding and let
it run after the real fix is applied?

The performance of drop_caches doesn't seem critical, especially with
gigapages. tmpfs doesn't seem to be optimized away from drop_caches
and the gain would be bigger for tmpfs if THP is not enabled in the
mount, so I'm not sure if we should worry about hugetlbfs first.

Thanks,
Andrea
