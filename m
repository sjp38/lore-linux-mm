Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACC2A6B039F
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 10:59:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z36so16499733wrc.14
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 07:59:12 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b190si3810298wmd.47.2017.03.31.07.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 07:59:11 -0700 (PDT)
Date: Fri, 31 Mar 2017 10:59:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v7 2/9] mm, memcg: Support to charge/uncharge
 multiple swap entries
Message-ID: <20170331145906.GC6408@cmpxchg.org>
References: <20170328053209.25876-1-ying.huang@intel.com>
 <20170328053209.25876-3-ying.huang@intel.com>
 <20170329165722.GB31821@cmpxchg.org>
 <87k277twip.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k277twip.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Thu, Mar 30, 2017 at 08:53:50AM +0800, Huang, Ying wrote:
> Johannes Weiner <hannes@cmpxchg.org> writes:
> > but there doesn't seem to be a reason to
> > pass @nr_entries when we have the struct page. Why can't this function
> > just check PageTransHuge() by itself?
> 
> Because sometimes we need to charge one swap entry for a THP.  Please
> take a look at the original add_to_swap() implementation.  For a THP,
> one swap entry will be allocated and charged to the mem cgroup before
> the THP is split.  And I think it is not easy to change this, because we
> don't want to split THP if the mem cgroup for swap exceeds its limit.

I think we do. Let's continue this discussion in the 9/9 subthread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
