Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 231066B024D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 22:04:11 -0400 (EDT)
Date: Wed, 28 Jul 2010 10:04:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/6] writeback: reduce calls to global_page_state in
 balance_dirty_pages()
Message-ID: <20100728020407.GA9819@localhost>
References: <20100711020656.340075560@intel.com>
 <20100711021748.735126772@intel.com>
 <20100726151946.GH3280@quack.suse.cz>
 <20100727035941.GA15007@localhost>
 <20100727091220.GD3358@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100727091220.GD3358@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Richard Kennedy <richard@rsk.demon.co.uk>, Dave Chinner <david@fromorbit.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > The global threshold check is added in place of clip_bdi_dirty_limit()
> > for safety and not intended as a behavior change. If ever leading to
> > big behavior change and regression, that it would be indicating some
> > too permissive per-bdi threshold calculation.
> > 
> > Did you see the global dirty threshold get exceeded when writing to 2+
> > devices? Occasional small exceeding should be OK though. I tried the
> > following debug patch and see no warnings when doing two concurrent cp
> > over local disk and NFS.
>   Oops, sorry. I've misread the code. You're right. There shouldn't be a big
> change in the behavior.

It does indicate a missing point in the changelog. The paragraph is
updated to:

        We now set and clear dirty_exceeded not only based on bdi dirty limits,
        but also on the global dirty limit. The global limit check is added in
        place of clip_bdi_dirty_limit() for safety and not intended as a
        behavior change. The bdi limits should be tight enough to keep all dirty
        pages under the global limit at most time; occasional small exceeding
        should be OK though. The change makes the logic more obvious: the global
        limit is the ultimate goal and shall be always imposed.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
