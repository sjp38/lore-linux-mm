Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id C2AFD6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:51:28 -0400 (EDT)
Received: by wibg7 with SMTP id g7so67995723wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 00:51:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id el10si2858487wjd.180.2015.03.25.00.51.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 00:51:27 -0700 (PDT)
Date: Wed, 25 Mar 2015 08:51:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Remove usages of ACCESS_ONCE
Message-ID: <20150325075123.GA22386@dhcp22.suse.cz>
References: <1427150680.2515.36.camel@j-VirtualBox>
 <20150324103003.GC14241@dhcp22.suse.cz>
 <1427221835.2515.52.camel@j-VirtualBox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427221835.2515.52.camel@j-VirtualBox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Low <jason.low2@hp.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, Rik van Riel <riel@redhat.com>

On Tue 24-03-15 11:30:35, Jason Low wrote:
> On Tue, 2015-03-24 at 11:30 +0100, Michal Hocko wrote:
> > On Mon 23-03-15 15:44:40, Jason Low wrote:
> > > Commit 38c5ce936a08 converted ACCESS_ONCE usage in gup_pmd_range() to
> > > READ_ONCE, since ACCESS_ONCE doesn't work reliably on non-scalar types.
> > > 
> > > This patch removes the rest of the usages of ACCESS_ONCE, and use
> > > READ_ONCE for the read accesses. This also makes things cleaner,
> > > instead of using separate/multiple sets of APIs.
> > > 
> > > Signed-off-by: Jason Low <jason.low2@hp.com>
> > 
> > Makes sense to me. I would prefer a patch split into two parts. One which
> > changes potentially dangerous usage of ACCESS_ONCE and the cleanup. This
> > will make the life of those who backport patches into older kernels
> > easier a bit.
> 
> Okay, so have a patch 1 which fixes the following:
> 
>     pte_t pte = ACCESS_ONCE(*ptep);
>     pgd_t pgd = ACCESS_ONCE(*pgdp);
> 
> and the rest of the changes in the cleanup patch 2?

Thanks!

> 
> > I won't insist though.
> > 
> > Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> Thanks,
> Jason
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
