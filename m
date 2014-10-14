Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 960826B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 19:34:33 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so128171pdj.13
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 16:34:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id dc5si14067307pdb.246.2014.10.14.16.34.32
        for <linux-mm@kvack.org>;
        Tue, 14 Oct 2014 16:34:32 -0700 (PDT)
Date: Tue, 14 Oct 2014 16:35:06 -0700
From: David Cohen <david.a.cohen@linux.intel.com>
Subject: Re: [PATCH 2/2] mm: verify compound order when freeing a page
Message-ID: <20141014233506.GB2889@psi-dev26.jf.intel.com>
References: <1413317800-25450-1-git-send-email-yuzhao@google.com>
 <1413317800-25450-2-git-send-email-yuzhao@google.com>
 <20141014202955.GA2889@psi-dev26.jf.intel.com>
 <543DACFB.2060405@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <543DACFB.2060405@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Yu Zhao <yuzhao@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 14, 2014 at 07:08:43PM -0400, Sasha Levin wrote:
> On 10/14/2014 04:29 PM, David Cohen wrote:
> >> +	VM_BUG_ON(PageTail(page));
> >> > +	VM_BUG_ON(PageHead(page) && compound_order(page) != order);
> > It may be too severe. AFAIU we're not talking about a fatal error.
> > How about VM_WARN_ON()?
> 
> VM_BUG_ON() should catch anything which is not "supposed" to happen,
> and not just the severe stuff. Unlike BUG_ON, VM_BUG_ON only gets
> hit with mm debugging enabled.

Thanks for pointing that out :)
VM_WARN_ON*() is recent, so there isn't much examples when to use it.
I considered the below case similar to this patch. But your point does
make sense anyway.

commit 82f71ae4a2b829a25971bdf54b4d0d3d69d3c8b7
Author: Konstantin Khlebnikov <koct9i@gmail.com>
Date:   Wed Aug 6 16:06:36 2014 -0700

    mm: catch memory commitment underflow
    
    Print a warning (if CONFIG_DEBUG_VM=y) when memory commitment becomes
    too negative.
    
    This shouldn't happen any more - the previous two patches fixed the
    committed_as underflow issues.

    [akpm@linux-foundation.org: use VM_WARN_ONCE, per Dave]


Br, David

> 
> 
> Thanks,
> Sasha
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
