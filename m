Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABEC6B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 10:47:01 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id d63so1943793wma.4
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 07:47:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a19si9924666wra.452.2018.02.01.07.46.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Feb 2018 07:47:00 -0800 (PST)
Date: Thu, 1 Feb 2018 16:46:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] few MM topics
Message-ID: <20180201154655.GN21609@dhcp22.suse.cz>
References: <20180124092649.GC21134@dhcp22.suse.cz>
 <20180131192104.GD4841@magnolia>
 <20180131202438.GA21609@dhcp22.suse.cz>
 <20180131234126.oobqdp6ibcayduu3@destitution>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180131234126.oobqdp6ibcayduu3@destitution>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Rik van Riel <riel@surriel.com>, linux-nvme@lists.infradead.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org

On Thu 01-02-18 10:41:26, Dave Chinner wrote:
> On Wed, Jan 31, 2018 at 09:24:38PM +0100, Michal Hocko wrote:
[...]
> > This would both document the context
> > and also limit NOFS allocations to bare minumum.
> 
> Yup, most of XFS already uses implicit GFP_NOFS allocation calls via
> the transaction context process flag manipulation.

Yeah, xfs is in quite a good shape. There are still around 40+ KM_NOFS
users. Are there any major obstacles to remove those? Or is this just
"send patches" thing.

Compare that to
$ git grep GFP_NOFS -- fs/btrfs/ | wc -l
272
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
