Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 480596B0255
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 13:29:18 -0400 (EDT)
Received: by wijp15 with SMTP id p15so106437130wij.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 10:29:17 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id kz6si34676142wjc.27.2015.08.18.10.29.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 10:29:16 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so101002981wic.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 10:29:16 -0700 (PDT)
Date: Tue, 18 Aug 2015 19:29:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC -v2 7/8] btrfs: Prevent from early transaction abort
Message-ID: <20150818172914.GO5033@dhcp22.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-8-git-send-email-mhocko@kernel.org>
 <20150818104031.GF5033@dhcp22.suse.cz>
 <20150818171144.GA5206@ret.DHCP.TheFacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150818171144.GA5206@ret.DHCP.TheFacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <clm@fb.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>

On Tue 18-08-15 13:11:44, Chris Mason wrote:
> On Tue, Aug 18, 2015 at 12:40:32PM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Btrfs relies on GFP_NOFS allocation when commiting the transaction but
> > since "mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM"
> > those allocations are allowed to fail which can lead to a pre-mature
> > transaction abort:
> 
> I can either put the btrfs nofail ones on my pull for Linus, or you can
> add my sob and send as one unit.  Just let me know how you'd rather do
> it.

OK, I will rephrase the changelogs (tomorrow) to not refer to an
unmerged patch and would appreciate if you can take them and route them
through your tree. I will then drop them from my pile.

Thanks.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
