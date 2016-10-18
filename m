Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE7CD6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:02:51 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id gg9so231724808pac.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:02:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id l5si32704044pgj.98.2016.10.18.08.02.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 08:02:45 -0700 (PDT)
Date: Tue, 18 Oct 2016 17:02:43 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mmap_sem bottleneck
Message-ID: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
References: <ea12b8ee-1892-fda1-8a83-20fdfdfa39c4@linux.vnet.ibm.com>
 <20161017125130.GU3142@twins.programming.kicks-ass.net>
 <4661f9fd-a239-ee82-476e-a5d039d8abee@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4661f9fd-a239-ee82-476e-a5d039d8abee@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Davidlohr Bueso <dbueso@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Oct 18, 2016 at 04:50:10PM +0200, Laurent Dufour wrote:
> On 17/10/2016 14:51, Peter Zijlstra wrote:

> > Latest version is here:
> > 
> >   https://lkml.kernel.org/r/20141020215633.717315139@infradead.org
> > 
> > Plenty of bits left to sort with that, but the general idea is to use
> > the split page-table locks (PTLs) as range lock for the mmap_sem.
> 
> Thanks Peter for the pointer,
> 
> It sounds that some parts of this series are already upstream, like the
> use of the fault_env structure,

Right, Kirill picked that up.

> but the rest of the code need some
> refresh to apply on the latest kernel. I'll try to update your series
> and will give it a try asap.
> 
> This being said, I'm wondering if the concern Kirill raised about the
> VMA sequence count handling are still valid...

Yes, I think they are. I don't think I put much time into it after that
exchange :-(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
