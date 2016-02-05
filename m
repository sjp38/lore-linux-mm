Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id C10234403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 21:15:50 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id 5so4945427igt.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 18:15:50 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id z18si24024407igq.63.2016.02.04.18.15.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 18:15:50 -0800 (PST)
Date: Fri, 5 Feb 2016 11:15:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 00/12] MADV_FREE support
Message-ID: <20160205021557.GA11598@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>

On Thu, Jan 28, 2016 at 08:16:25AM +0100, Michael Kerrisk (man-pages) wrote:
> Hello Minchan,
> 
> On 11/30/2015 07:39 AM, Minchan Kim wrote:
> > In v4, Andrew wanted to settle in old basic MADV_FREE and introduces
> > new stuffs(ie, lazyfree LRU, swapless support and lazyfreeness) later
> > so this version doesn't include them.
> > 
> > I have been tested it on mmotm-2015-11-25-17-08 with additional
> > patch[1] from Kirill to prevent BUG_ON which he didn't send to
> > linux-mm yet as formal patch. With it, I couldn't find any
> > problem so far.
> > 
> > Note that this version is based on THP refcount redesign so
> > I needed some modification on MADV_FREE because split_huge_pmd
> > doesn't split a THP page any more and pmd_trans_huge(pmd) is not
> > enough to guarantee the page is not THP page.
> > As well, for MAVD_FREE lazy-split, THP split should respect
> > pmd's dirtiness rather than marking ptes of all subpages dirty
> > unconditionally. Please, review last patch in this patchset.
> 
> Now that MADV_FREE has been merged, would you be willing to write
> patch to the madvise(2) man page that describes the semantics, 
> noes limitations and restrictions, and (ideally) has some sentences
> describing use cases?
> 

Hello Michael,

Could you review this patch?

Thanks.
