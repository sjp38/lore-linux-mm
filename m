Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id C1FBD6B0038
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 12:05:38 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so5777080pbc.18
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 09:05:38 -0700 (PDT)
Date: Mon, 30 Sep 2013 09:05:34 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Message-ID: <20130930160534.GB2125@tassilo.jf.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
 <20130924234950.GC2018@tassilo.jf.intel.com>
 <20130930101300.GD2425@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130930101300.GD2425@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 30, 2013 at 11:13:00AM +0100, Mel Gorman wrote:
> On Tue, Sep 24, 2013 at 04:49:50PM -0700, Andi Kleen wrote:
> > > Sigh.  A pox on whoever thought up huge pages. 
> > 
> > managing 1TB+ of memory in 4K chunks is just insane.
> > The question of larger pages is not "if", but only "when".
> > 
> 
> Remember that there are at least two separate issues there. One is the
> handling data in larger granularities than a 4K page and the second is
> the TLB, pagetable etc handling. They are not necessarily the same problem.

It's the same problem in the end.

The hardware is struggling with 4K pages too (both i and d)

I expect longer term TLB/page optimization to have far more important
than all this NUMA placement work that people spend so much
time on.


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
