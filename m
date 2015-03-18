Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 85D356B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:51:50 -0400 (EDT)
Received: by qcaz10 with SMTP id z10so40077250qca.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:51:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h98si16805824qkh.64.2015.03.18.07.51.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 07:51:49 -0700 (PDT)
Message-ID: <55098F3B.7070000@redhat.com>
Date: Wed, 18 Mar 2015 10:44:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in page_cache_read
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <1426687766-518-1-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 03/18/2015 10:09 AM, Michal Hocko wrote:
> page_cache_read has been historically using page_cache_alloc_cold to
> allocate a new page. This means that mapping_gfp_mask is used as the
> base for the gfp_mask. Many filesystems are setting this mask to
> GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
> however, not called from the fs layer 

Is that true for filesystems that have directories in
the page cache?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
