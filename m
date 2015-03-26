Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id BED7D6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 05:53:06 -0400 (EDT)
Received: by wibg7 with SMTP id g7so141683434wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 02:53:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si9769903wiy.32.2015.03.26.02.53.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 02:53:05 -0700 (PDT)
Date: Thu, 26 Mar 2015 10:53:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150326095302.GA15257@dhcp22.suse.cz>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
 <20150318145528.GK17241@dhcp22.suse.cz>
 <20150319071439.GE28621@dastard>
 <20150319124441.GC12466@dhcp22.suse.cz>
 <20150320034820.GH28621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150320034820.GH28621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 20-03-15 14:48:20, Dave Chinner wrote:
> On Thu, Mar 19, 2015 at 01:44:41PM +0100, Michal Hocko wrote:
[...]
> > Or did I miss your point? Are you concerned about some fs overloading
> > filemap_fault and do some locking before delegating to filemap_fault?
> 
> The latter:
> 
> https://git.kernel.org/cgit/linux/kernel/git/dgc/linux-xfs.git/commit/?h=xfs-mmap-lock&id=de0e8c20ba3a65b0f15040aabbefdc1999876e6b

Hmm. I am completely unfamiliar with the xfs code but my reading of
964aa8d9e4d3..723cac484733 is that the newly introduced lock should be
OK from the reclaim recursion POV. It protects against truncate and
punch hole, right? Or are there any internal paths which I am missing
and would cause problems if we do GFP_FS with XFS_MMAPLOCK_SHARED held?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
