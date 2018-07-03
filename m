Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 762436B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 00:37:43 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n3-v6so405193pgp.21
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 21:37:43 -0700 (PDT)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id i8-v6si250358pfo.128.2018.07.02.21.37.41
        for <linux-mm@kvack.org>;
        Mon, 02 Jul 2018 21:37:42 -0700 (PDT)
Date: Tue, 3 Jul 2018 14:37:38 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2] fs: xfs: use BUG_ON if writepage call comes from
 direct reclaim
Message-ID: <20180703043738.GG2234@dastard>
References: <1530591079-33813-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530591079-33813-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530591079-33813-2-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, tytso@mit.edu, adilger.kernel@dilger.ca, darrick.wong@oracle.com, dchinner@redhat.com, akpm@linux-foundation.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 03, 2018 at 12:11:19PM +0800, Yang Shi wrote:
> direct reclaim doesn't write out filesystem page, only kswapd could do
> this. So, if it is called from direct relaim, it is definitely a bug.
> 
> And, Mel Gorman mentioned "Ultimately, this will be a BUG_ON." in commit
> 94054fa3fca1fd78db02cb3d68d5627120f0a1d4 ("xfs: warn if direct reclaim
> tries to writeback pages"),
> 
> It has been many years since that commit, so it should be safe to
> elevate WARN_ON to BUG_ON now.

NACK.

The existing code warns and then handles the situation gracefully -
this is the appropriate way to handle incorrect calling contexts.
There is absolutely no good reason to panic production kernels
in situations like this.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
