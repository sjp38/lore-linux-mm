Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 80CE16B0278
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 07:23:23 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p190so4197727wmd.0
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 04:23:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i24si50448edg.196.2017.12.04.04.23.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 04:23:22 -0800 (PST)
Date: Mon, 4 Dec 2017 13:23:15 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: stalled MM patches
Message-ID: <20171204122315.GA17047@quack2.suse.cz>
References: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
 <20171201183035.GH19394@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201183035.GH19394@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexandru Moise <00moses.alexander00@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrey Vagin <avagin@openvz.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, "Artem S. Tashkinov" <t.artem@lycos.com>, Balbir Singh <bsingharora@gmail.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Glauber Costa <glommer@openvz.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Ingo Molnar <mingo@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Maxim Patlasov <MPatlasov@parallels.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Punit Agrawal <punit.agrawal@arm.com>, Rik van Riel <riel@redhat.com>, Shiraz Hashim <shashim@codeaurora.org>, Tan Xiaojun <tanxiaojun@huawei.com>, Theodore Ts'o <tytso@mit.edu>, Vinayak Menon <vinmenon@codeaurora.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Yisheng Xie <xieyisheng1@huawei.com>, zhong jiang <zhongjiang@huawei.com>, linux-mm@kvack.org

On Fri 01-12-17 10:30:35, Darrick J. Wong wrote:
> On Thu, Nov 30, 2017 at 02:14:23PM -0800, Andrew Morton wrote:
> > 
> > I'm sitting on a bunch of patches of varying ages which are stuck for
> > various reason.  Can people please take a look some time and assist
> > with getting them merged, dropped or fixed?
> > 
> > I'll send them all out in a sec.  I have rough notes (which might be
> > obsolete) and additional details can be found by following the Link: in
> > the individual patches.
> > 
> > Thanks.
> > 
> > Subject: mm: skip HWPoisoned pages when onlining pages
> > 
> >   mhocko had issues with this one.
> > 
> > Subject: mm/mempolicy: remove redundant check in get_nodes
> > Subject: mm/mempolicy: fix the check of nodemask from user
> > Subject: mm/mempolicy: add nodes_empty check in SYSC_migrate_pages
> > 
> >   Three patch series.  Stuck because vbabka wasn't happy with #3.
> > 
> > Subject: mm: memcontrol: eliminate raw access to stat and event counters
> > Subject: mm: memcontrol: implement lruvec stat functions on top of each other
> > Subject: mm: memcontrol: fix excessive complexity in memory.stat reporting
> > 
> >   Three patch series.  Stuck because #3 caused fengguang-bot to
> >   report "BUG: using __this_cpu_xchg() in preemptible"
> > 
> > Subject: mm/madvise: enable soft offline of HugeTLB pages at PUD level
> > 
> >   Hoping for Kirill review.  I wanted additional code comments (I
> >   think).  mhocko nacked it.
> > 
> > Subject: mm: readahead: increase maximum readahead window
> > 
> >   Darrick said he was going to do some testing.
> 
> FWIW I thought Jan said was going to do some testing on a recent kernel...

Yeah, tests are running. Will report results once I get them.

> Referencing the patch itself: ext3 on 4.4 is a bit old for a 4.16 patch, yes?

I think I already replied to this concern - this is just an unclear
statement in the changelog. ext3 == ext4 mounted with -o nodelalloc (that
happens today if you try to mount a filesystem using ext3 fstype).

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
