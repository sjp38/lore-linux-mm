Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E2EA16B025F
	for <linux-mm@kvack.org>; Mon, 23 May 2016 13:29:36 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so31852240wma.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:29:36 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id h143si17507310wme.13.2016.05.23.10.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 10:29:35 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id 67so17178148wmg.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:29:35 -0700 (PDT)
Date: Mon, 23 May 2016 20:29:29 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [PATCH 0/3] mm, thp: remove duplication and fix locking issues
 in swapin
Message-ID: <20160523172929.GA4406@debian>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On Mon, May 23, 2016 at 08:14:08PM +0300, Ebru Akagunduz wrote:
> This patch series removes duplication of included header
> and fixes locking inconsistency in khugepaged swapin
> 
> Ebru Akagunduz (3):
>   mm, thp: remove duplication of included header
>   mm, thp: fix possible circular locking dependency caused by
>     sum_vm_event()
>   mm, thp: make swapin readahead under down_read of mmap_sem
> 
>  mm/huge_memory.c | 39 ++++++++++++++++++++++++++++++---------
>  1 file changed, 30 insertions(+), 9 deletions(-)
> 

Hi Andrew,

I prepared this patch series to solve rest of
problems of khugepaged swapin.

I have seen the discussion:
http://marc.info/?l=linux-mm&m=146373278424897&w=2

In my opinion, checking whether kswapd is wake up
could be good.

It's up to you. I can take an action according to community's decision.

Here is the last status of the discussion:

"
Optimistic swapin collapsing

1. it could be too optimisitic to lose the gain due to evicting workingset
2. let's detect memory pressure
3. current allocstall magic is not a good idea.
4. let's change the design from optimistic to conservative
5. how we can be conservative
6. two things - detect hot pages and threshold of swap pte
7. threhsold of swap pte is already done so remained thing is detect hot page
8. how to detect hot page - let's use young bit
9. Now, we are conservatie so we will swap in when it's worth
10. let's remove allocstall magic

I think it's not off-topic.
Anyway, it's just my thought and don't have any real workload and objection.
Feel free to ignore.
"

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
