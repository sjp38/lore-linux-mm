Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BAB758E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 17:10:58 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g7so12983159plp.10
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 14:10:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bj11si13739354plb.21.2018.12.18.14.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 14:10:57 -0800 (PST)
Date: Tue, 18 Dec 2018 14:10:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] hugetlbfs: Use i_mmap_rwsem to fix page
 fault/truncate race
Message-Id: <20181218141053.e2725111ce5cc91493efab5f@linux-foundation.org>
In-Reply-To: <dbc4abb9-aa7b-6515-0f37-23a77b50ff6e@oracle.com>
References: <20181203200850.6460-1-mike.kravetz@oracle.com>
	<20181203200850.6460-3-mike.kravetz@oracle.com>
	<27f8893b-57b3-088d-2d48-9e8acc5987bd@linux.ibm.com>
	<f6fd9491-4b3d-16ca-f606-025c78756936@oracle.com>
	<dbc4abb9-aa7b-6515-0f37-23a77b50ff6e@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, stable@vger.kernel.org

On Mon, 17 Dec 2018 16:17:52 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> ...
>
> > As you suggested in a comment to the subsequent patch, it would be better to
> > combine the patches and remove the dead code when it becomes dead.  I will
> > work on that.  Actually some of the code in patch 3 applies to patch 1 and
> > some applies to patch 2.  So, it will not be simply combining patch 2 and 3.
> 
> On second thought, the cleanups in patch 3 only apply to patch 2.  So, just
> combining those two patches with a slightly updated commit message as below
> makes the most sense.

All confused.  I dropped the current version, let's try again.

This:

> Hoping to get more comments on the overall direction and locking changes
> of this and the previous patch.

and this:

> Cc: <stable@vger.kernel.org>
> Fixes: ebed4bfc8da8 ("hugetlb: fix absurd HugePages_Rsvd")

make for a hot combination.  Could people please prioritize review of
this code?

Perhaps a refresh and resend is in order.
