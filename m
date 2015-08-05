Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id B81126B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 12:32:33 -0400 (EDT)
Received: by wicgj17 with SMTP id gj17so199924745wic.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 09:32:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si29465117wiz.76.2015.08.05.09.32.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 09:32:32 -0700 (PDT)
Date: Wed, 5 Aug 2015 18:32:12 +0200
From: David Sterba <dsterba@suse.com>
Subject: Re: [RFC 8/8] btrfs: use __GFP_NOFAIL in alloc_btrfs_bio
Message-ID: <20150805163211.GB31669@twin.jikos.cz>
Reply-To: dsterba@suse.com
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-9-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438768284-30927-9-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>

On Wed, Aug 05, 2015 at 11:51:24AM +0200, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> alloc_btrfs_bio is relying on GFP_NOFS to allocate a bio but since "mm:
> page_alloc: do not lock up GFP_NOFS allocations upon OOM" this is
> allowed to fail which can lead to
> [   37.928625] kernel BUG at fs/btrfs/extent_io.c:4045
> 
> This is clearly undesirable and the nofail behavior should be explicit
> if the allocation failure cannot be tolerated.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: David Sterba <dsterba@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
