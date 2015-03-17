Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id CCF346B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 22:04:01 -0400 (EDT)
Received: by pabyw6 with SMTP id yw6so82243904pab.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 19:04:01 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id nt3si26009938pdb.180.2015.03.16.19.03.59
        for <linux-mm@kvack.org>;
        Mon, 16 Mar 2015 19:04:01 -0700 (PDT)
Date: Tue, 17 Mar 2015 11:04:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v4 0/5] mm: cma: add some debug information for CMA
Message-ID: <20150317020401.GC19483@js1304-P5Q-DELUXE>
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
 <20150317014306.GB19483@js1304-P5Q-DELUXE>
 <5507894A.2080008@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5507894A.2080008@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

On Mon, Mar 16, 2015 at 09:54:18PM -0400, Sasha Levin wrote:
> On 03/16/2015 09:43 PM, Joonsoo Kim wrote:
> > On Mon, Mar 16, 2015 at 07:06:55PM +0300, Stefan Strogin wrote:
> >> > Hi all.
> >> > 
> >> > Here is the fourth version of a patch set that adds some debugging facility for
> >> > CMA.
> >> > 
> >> > This patch set is based on next-20150316.
> >> > It is also available on git:
> >> > git://github.com/stefanstrogin/linux -b cmainfo-v4
> >> > 
> >> > We want an interface to see a list of currently allocated CMA buffers and some
> >> > useful information about them (like /proc/vmallocinfo but for physically
> >> > contiguous buffers allocated with CMA).
> >> > 
> >> > For example. We want a big (megabytes) CMA buffer to be allocated in runtime
> >> > in default CMA region. If someone already uses CMA then the big allocation
> >> > could fail. If it happened then with such an interface we could find who used
> >> > CMA at the moment of failure, who caused fragmentation and so on. Ftrace also
> >> > would be helpful here, but with ftrace we can see the whole history of
> >> > allocations and releases, whereas with this patch set we can see a snapshot of
> >> > CMA region with actual information about its allocations.
> > Hello,
> > 
> > Hmm... I still don't think that this is really helpful to find root
> > cause of fragmentation. Think about following example.
> > 
> > Assume 1024 MB CMA region.
> > 
> > 128 MB allocation * 4
> > 1 MB allocation
> > 128 MB allocation
> > 128 MB release * 4 (first 4)
> > try 512 MB allocation
> > 
> > With above sequences, fragmentation happens and 512 MB allocation would
> > be failed. We can get information about 1 MB allocation and 128 MB one
> > from the buffer list as you suggested, but, fragmentation are related
> > to whole sequence of allocation/free history, not snapshot of allocation.
> 
> This is solvable by dumping task->comm in the tracepoint patch (1/5), right?

Yes, it can be solved by 1/5.
I mean that I'm not sure patch 4/5 is really needed or not.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
