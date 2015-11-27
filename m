Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id DC9C36B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 12:05:25 -0500 (EST)
Received: by wmvv187 with SMTP id v187so78620845wmv.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 09:05:25 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id 14si11688642wmq.78.2015.11.27.09.05.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 09:05:24 -0800 (PST)
Received: by wmvv187 with SMTP id v187so78620269wmv.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 09:05:24 -0800 (PST)
Date: Fri, 27 Nov 2015 18:05:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Allow GFP_IOFS for page_cache_read page cache
 allocation
Message-ID: <20151127170522.GL2493@dhcp22.suse.cz>
References: <1447251233-14449-1-git-send-email-mhocko@kernel.org>
 <20151112095301.GA25265@quack.suse.cz>
 <20151126150820.GI7953@dhcp22.suse.cz>
 <56588789.1010300@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56588789.1010300@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, Mark Fasheh <mfasheh@suse.com>, ocfs2-devel@oss.oracle.com, ceph-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri 27-11-15 17:40:41, Vlastimil Babka wrote:
> On 11/26/2015 04:08 PM, Michal Hocko wrote:
> >On Thu 12-11-15 10:53:01, Jan Kara wrote:
> >>On Wed 11-11-15 15:13:53, mhocko@kernel.org wrote:
> >>>
> >>>Hi,
> >>>this has been posted previously as a part of larger GFP_NOFS related
> >>>patch set (http://lkml.kernel.org/r/1438768284-30927-1-git-send-email-mhocko%40kernel.org)
> >>>but I think it makes sense to discuss it even out of that scope.
> >>>
> >>>I would like to hear FS and other MM people about the proposed interface.
> >>>Using mapping_gfp_mask blindly doesn't sound good to me and vm_fault
> >>>looks like a proper channel to communicate between MM and FS layers.
> >>>
> >>>Comments? Are there any better ideas?
> >>
> >>Makes sense to me and the filesystems I know should be fine with this
> >>(famous last words ;). Feel free to add:
> >>
> >>Acked-by: Jan Kara <jack@suse.com>
> >
> >Thanks a lot! Are there any objections from other fs/mm people?
> 
> Please replace "GFP_IOFS" in the subject, as the "flag" has been removed
> recently. Otherwise

Done.
mm: Allow GFP_{FS,IO} for page_cache_read page cache allocation

> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
