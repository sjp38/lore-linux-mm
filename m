Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 0F2396B0070
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 10:37:54 -0400 (EDT)
Date: Fri, 3 Aug 2012 16:37:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm] mm: hugetlbfs: Correctly populate shared pmd
Message-ID: <20120803143748.GD8434@dhcp22.suse.cz>
References: <20120802141656.GB18084@dhcp22.suse.cz>
 <CAJd=RBDnzbLpqsVkishsZmB518mCu0Go0o2ZOGdHj62qRfLnAg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBDnzbLpqsVkishsZmB518mCu0Go0o2ZOGdHj62qRfLnAg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>

On Fri 03-08-12 22:16:52, Hillf Danton wrote:
> On Thu, Aug 2, 2012 at 10:16 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > This patch addresses the issue by moving pmd_alloc into huge_pmd_share
> > which guarantees that the shared pud is populated in the same
> > critical section as pmd.
> 
> Is i_mmap_mutex for guarding new pmd allocation?

It doesn't guard the pmd allocation itself it just makes sure that pud
population and pmd_allocation are done atomicaly wrt. other processes to
share the same pmd because sharing is synchronized by i_mmap_mutex.

> Is regression introduced if sharing is unavailable?

No. The bug is about the sharing as the changelog describes.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
