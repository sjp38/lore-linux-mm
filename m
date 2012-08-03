Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 09A316B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 10:16:53 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so847051vcb.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 07:16:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120802141656.GB18084@dhcp22.suse.cz>
References: <20120802141656.GB18084@dhcp22.suse.cz>
Date: Fri, 3 Aug 2012 22:16:52 +0800
Message-ID: <CAJd=RBDnzbLpqsVkishsZmB518mCu0Go0o2ZOGdHj62qRfLnAg@mail.gmail.com>
Subject: Re: [PATCH -mm] mm: hugetlbfs: Correctly populate shared pmd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>

On Thu, Aug 2, 2012 at 10:16 PM, Michal Hocko <mhocko@suse.cz> wrote:
> This patch addresses the issue by moving pmd_alloc into huge_pmd_share
> which guarantees that the shared pud is populated in the same
> critical section as pmd.

Is i_mmap_mutex for guarding new pmd allocation?
Is regression introduced if sharing is unavailable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
