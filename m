Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C85936B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 17:46:47 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id b6so2123116plx.3
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 14:46:47 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id h15-v6si314851pli.212.2018.02.01.14.46.45
        for <linux-mm@kvack.org>;
        Thu, 01 Feb 2018 14:46:46 -0800 (PST)
Date: Fri, 2 Feb 2018 09:47:38 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] few MM topics
Message-ID: <20180201224738.y3vsrh7ekdugm5ae@destitution>
References: <20180124092649.GC21134@dhcp22.suse.cz>
 <20180131192104.GD4841@magnolia>
 <20180131202438.GA21609@dhcp22.suse.cz>
 <20180131234126.oobqdp6ibcayduu3@destitution>
 <20180201154655.GN21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180201154655.GN21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Rik van Riel <riel@surriel.com>, linux-nvme@lists.infradead.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org

On Thu, Feb 01, 2018 at 04:46:55PM +0100, Michal Hocko wrote:
> On Thu 01-02-18 10:41:26, Dave Chinner wrote:
> > On Wed, Jan 31, 2018 at 09:24:38PM +0100, Michal Hocko wrote:
> [...]
> > > This would both document the context
> > > and also limit NOFS allocations to bare minumum.
> > 
> > Yup, most of XFS already uses implicit GFP_NOFS allocation calls via
> > the transaction context process flag manipulation.
> 
> Yeah, xfs is in quite a good shape. There are still around 40+ KM_NOFS
> users. Are there any major obstacles to remove those? Or is this just
> "send patches" thing.

They need to be looked at on a case by case basis - many of
them are the "shut up lockdep false positives" workarounds because
the code is called from multiple memory reclaim contexts. In other
cases they might actually be needed. If you send patches, it'll
kinda force us to look at them and say yay/nay :P

> Compare that to
> $ git grep GFP_NOFS -- fs/btrfs/ | wc -l
> 272

Fair point. :P

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
