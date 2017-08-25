Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 347FC44088B
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 20:02:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 63so3613609pgc.0
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 17:02:09 -0700 (PDT)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id a66si3846049pli.531.2017.08.24.17.02.07
        for <linux-mm@kvack.org>;
        Thu, 24 Aug 2017 17:02:08 -0700 (PDT)
Date: Fri, 25 Aug 2017 10:01:37 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] xfs: Drop setting redundant PF_KSWAPD in kswapd context
Message-ID: <20170825000137.GI21024@dastard>
References: <20170824104247.8288-1-khandual@linux.vnet.ibm.com>
 <20170824105635.GA5965@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824105635.GA5965@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org, dchinner@redhat.com, bfoster@redhat.com, sandeen@sandeen.net

On Thu, Aug 24, 2017 at 12:56:35PM +0200, Michal Hocko wrote:
> On Thu 24-08-17 16:12:47, Anshuman Khandual wrote:
> > xfs_btree_split() calls xfs_btree_split_worker() with args.kswapd set
> > if current->flags alrady has PF_KSWAPD. Hence we should not again add
> > PF_KSWAPD into the current flags inside kswapd context. So drop this
> > redundant flag addition.
> 
> I am not familiar with the code but your change seems incorect. The
> whole point of args->kswapd is to convey the kswapd context to the
> worker which is obviously running in a different context. So this patch
> loses the kswapd context.

Yup. That's what the code does, and removing the PF_KSWAPD from it
will break it.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
