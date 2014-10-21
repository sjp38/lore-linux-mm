Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C20086B0092
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 06:17:49 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id ft15so1055231pdb.30
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 03:17:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id tw4si10657579pab.24.2014.10.21.03.17.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 03:17:48 -0700 (PDT)
Date: Tue, 21 Oct 2014 12:17:42 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [BUG] mm, thp: khugepaged can't allocate on requested node when
 confined to a cpuset
Message-ID: <20141021101742.GT23531@worktop.programming.kicks-ass.net>
References: <20141008191050.GK3778@sgi.com>
 <20141014114828.GA6524@node.dhcp.inet.fi>
 <20141014145435.GA7369@worktop.fdxtended.com>
 <20141014173837.GA8919@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141014173837.GA8919@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Tue, Oct 14, 2014 at 08:38:37PM +0300, Kirill A. Shutemov wrote:
> On Tue, Oct 14, 2014 at 04:54:35PM +0200, Peter Zijlstra wrote:
> > > Is there a reason why we should respect cpuset limitation for kernel
> > > threads?
> > 
> > Yes, because we want to allow isolating CPUs from 'random' activity.
> 
> Okay, it makes sense for cpus_allowed. But we're talking about
> mems_allowed, right?
>  
> > 
> > > Should we bypass cpuset for PF_KTHREAD completely?
> > 
> > No. That'll break stuff.
> 
> Like what?

Like using cpusets for what they were designed for? We very much want to
allow moving kernel threads into limited cpusets in order to avoid
perturbing the 'important' work done elsewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
