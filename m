Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D50A46B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:42:21 -0400 (EDT)
Message-ID: <501A9164.5040304@redhat.com>
Date: Thu, 02 Aug 2012 10:40:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm: hugetlbfs: Correctly populate shared pmd
References: <20120802141656.GB18084@dhcp22.suse.cz>
In-Reply-To: <20120802141656.GB18084@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Larry Woodman <lwoodman@redhat.com>

On 08/02/2012 10:16 AM, Michal Hocko wrote:
> Hi Andrew,
> the following patch fixes yet-another race in the hugetlb pte sharing
> code reported by Larry. It is based on top of the current -mm tree but
> it cleanly applies to linus tree as well. It should go to stable as
> well. The bug is there for ages but this fix is possible only since 3.0
> because i_mmap_lock used to be a spinlock until 3d48ae45 which turned it
> into mutex and so we can call pmd_alloc.

> This patch addresses the issue by moving pmd_alloc into huge_pmd_share
> which guarantees that the shared pud is populated in the same
> critical section as pmd. This also means that huge_pte_offset test in
> huge_pmd_share is serialized correctly now which in turn means that
> the success of the sharing will be higher as the racing tasks see the
> pud and pmd populated together.
>
> Race identified and changelog written mostly by Mel Gorman
> Reported-and-tested-by: Larry Woodman <lwoodman@redhat.com>
> Reviewed-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Reviewed-by: Rik van Riel <riel@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
