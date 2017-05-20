Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC1A280753
	for <linux-mm@kvack.org>; Fri, 19 May 2017 22:40:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e8so69080791pfl.4
        for <linux-mm@kvack.org>; Fri, 19 May 2017 19:40:48 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id e92si10044956plk.306.2017.05.19.19.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 19:40:47 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id e193so47496922pfh.0
        for <linux-mm@kvack.org>; Fri, 19 May 2017 19:40:47 -0700 (PDT)
Date: Fri, 19 May 2017 19:40:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
In-Reply-To: <591FA78E.9050307@huawei.com>
Message-ID: <alpine.LSU.2.11.1705191935220.11750@eggly.anvils>
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com> <591EBE71.7080402@huawei.com> <alpine.LSU.2.11.1705191453040.3819@eggly.anvils> <591F9A09.6010707@huawei.com> <alpine.LSU.2.11.1705191852360.11060@eggly.anvils>
 <591FA78E.9050307@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On Sat, 20 May 2017, Xishi Qiu wrote:
> 
> Here is a bug report form redhat: https://bugzilla.redhat.com/show_bug.cgi?id=1305620
> And I meet the bug too. However it is hard to reproduce, and 
> 624483f3ea82598("mm: rmap: fix use-after-free in __put_anon_vma") is not help.
> 
> From the vmcore, it seems that the page is still mapped(_mapcount=0 and _count=2),
> and the value of mapping is a valid address(mapping = 0xffff8801b3e2a101),
> but anon_vma has been corrupted.
> 
> Any ideas?

Sorry, no.  I assume that _mapcount has been misaccounted, for example
a pte mapped in on top of another pte; but cannot begin tell you where
in Red Hat's kernel-3.10.0-229.4.2.el7 that might happen.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
