Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B64B6B0008
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 03:45:40 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v14so2067696pgq.11
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 00:45:40 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w128si2421304pgb.460.2018.03.21.00.45.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 00:45:39 -0700 (PDT)
Date: Wed, 21 Mar 2018 15:42:49 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH v2 2/4] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Message-ID: <20180321074249.GA1855@aaronlu>
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <20180320085452.24641-3-aaron.lu@intel.com>
 <CAF7GXvovKsabDw88icK5c5xBqg6g0TomQdspfi4ikjtbg=XzGQ@mail.gmail.com>
 <20180321015944.GB28705@intel.com>
 <CAF7GXvrQG0+iPu8h13coo2QW7WxNhjHA1JAaOYoEBBB9-obRSQ@mail.gmail.com>
 <20180321045353.GC28705@intel.com>
 <CAF7GXvpzZassTEebX7nS0u_xynns=mxEF28rPBhXX9Yp4xQ3hw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAF7GXvpzZassTEebX7nS0u_xynns=mxEF28rPBhXX9Yp4xQ3hw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Tue, Mar 20, 2018 at 10:59:16PM -0700, Figo.zhang wrote:
> 2018-03-20 21:53 GMT-07:00 Aaron Lu <aaron.lu@intel.com>:
> 
> > On Tue, Mar 20, 2018 at 09:21:33PM -0700, Figo.zhang wrote:
> > > suppose that in free_one_page() will try to merge to high order anytime ,
> > > but now in your patch,
> > > those merge has postponed when system in low memory status, it is very
> > easy
> > > let system trigger
> > > low memory state and get poor performance.
> >
> > Merge or not merge, the size of free memory is not affected.
> >
> 
> yes, the total free memory is not impact, but will influence the higher
> order allocation.

Yes, that's correct.
