Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9C822280245
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 10:34:51 -0400 (EDT)
Received: by ykoo205 with SMTP id o205so63861974yko.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 07:34:51 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id y19si1799004wiv.10.2015.08.06.07.34.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 07:34:50 -0700 (PDT)
Received: by wijp15 with SMTP id p15so25229685wij.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 07:34:50 -0700 (PDT)
Date: Thu, 6 Aug 2015 16:34:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 0/8] Allow GFP_NOFS allocation to fail
Message-ID: <20150806143447.GD12827@dhcp22.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 05-08-15 20:58:25, Andreas Dilger wrote:
> On Aug 5, 2015, at 3:51 AM, mhocko@kernel.org wrote:
[...]
> > The rest are the FS specific patches to fortify allocations
> > requests which are really needed to finish transactions without RO
> > remounts. There might be more needed but my test case survives with
> > these in place.
> 
> Wouldn't it make more sense to order the fs-specific patches _before_
> the "GFP_NOFS can fail" patch (#3), so that once that patch is applied
> all known failures have already been fixed?  Otherwise it could show
> test failures during bisection that would be confusing.

As I write below. If maintainers consider them useful even when GFP_NOFS
doesn't fail I will reword them and resend. But you cannot fix the world
without breaking it first in this case ;)
 
> > They would obviously need some rewording if they are going to be
> > applied even without Patch3 and I will do that if respective
> > maintainers will take them. Ext3 and JBD are going away soon so they
> > might be dropped but they have been in the tree while I was testing
> > so I've kept them.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
