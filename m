Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8DA6B0292
	for <linux-mm@kvack.org>; Sun, 23 Jul 2017 22:46:45 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id r14so59038798qte.11
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 19:46:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f37si7972827qta.510.2017.07.23.19.46.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 19:46:44 -0700 (PDT)
Date: Mon, 24 Jul 2017 10:46:27 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH -mm -v2 00/12] mm, THP, swap: Delay splitting THP after
 swapped out
Message-ID: <20170724024622.GB12871@ming.t460p>
References: <20170623071303.13469-1-ying.huang@intel.com>
 <20170721162129.077f7d9b4c77c8593e47aed9@linux-foundation.org>
 <874lu2ircj.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <874lu2ircj.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@kernel.org>

On Mon, Jul 24, 2017 at 08:57:48AM +0800, Huang, Ying wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Fri, 23 Jun 2017 15:12:51 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
> >
> >> From: Huang Ying <ying.huang@intel.com>
> >> 
> >> Hi, Andrew, could you help me to check whether the overall design is
> >> reasonable?
> >> 
> >> Hi, Johannes and Minchan, Thanks a lot for your review to the first
> >> step of the THP swap optimization!  Could you help me to review the
> >> second step in this patchset?
> >> 
> >> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
> >> swap part of the patchset?  Especially [01/12], [02/12], [03/12],
> >> [04/12], [11/12], and [12/12].
> >> 
> >> Hi, Andrea and Kirill, could you help me to review the THP part of the
> >> patchset?  Especially [01/12], [03/12], [07/12], [08/12], [09/12],
> >> [11/12].
> >> 
> >> Hi, Johannes, Michal, could you help me to review the cgroup part of
> >> the patchset?  Especially [08/12], [09/12], and [10/12].
> >> 
> >> And for all, Any comment is welcome!
> >
> > I guess it's time for a resend.  Folks, could we please get some more
> > review&test going here?
> 
> Sure.  Will resend it ASAP.  And Thanks for reminding!
> 
> >> Because the THP swap writing support patch [06/12] needs to be rebased
> >> on multipage bvec patchset which hasn't been merged yet.  The [06/12]
> >> in this patchset is just a test patch and will be rewritten later.
> >> The patchset depends on multipage bvec patchset too.
> >
> > Are these dependency issues any simpler now?
> 
> Ming Lei has sent the v2 of multipage bvec patchset on June 26th.  Jens
> Axboe thinks the patchset will target v4.14.
> 
> https://lkml.org/lkml/2017/6/26/538

I will rebase the patchset against v4.13-rcX and send v3 out later.


Thanks,
Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
