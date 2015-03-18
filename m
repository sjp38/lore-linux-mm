Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3596B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:55:31 -0400 (EDT)
Received: by wifj2 with SMTP id j2so42082507wif.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:55:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hr1si3961321wib.114.2015.03.18.07.55.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 07:55:29 -0700 (PDT)
Date: Wed, 18 Mar 2015 15:55:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150318145528.GK17241@dhcp22.suse.cz>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55098F3B.7070000@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 18-03-15 10:44:11, Rik van Riel wrote:
> On 03/18/2015 10:09 AM, Michal Hocko wrote:
> > page_cache_read has been historically using page_cache_alloc_cold to
> > allocate a new page. This means that mapping_gfp_mask is used as the
> > base for the gfp_mask. Many filesystems are setting this mask to
> > GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
> > however, not called from the fs layer 
> 
> Is that true for filesystems that have directories in
> the page cache?

I haven't found any explicit callers of filemap_fault except for ocfs2
and ceph and those seem OK to me. Which filesystems you have in mind?

Btw. how would that work as we already have GFP_KERNEL allocation few
lines below?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
