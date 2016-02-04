Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C392F82963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 19:01:43 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id o185so23238060pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 16:01:43 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id 29si12364724pft.41.2016.02.03.16.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 16:01:43 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id w123so23363824pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 16:01:43 -0800 (PST)
Date: Wed, 3 Feb 2016 16:01:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 08/14] mm, oom: print symbolic gfp_flags in oom
 warning
In-Reply-To: <1453812353-26744-9-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1602031601280.10331@chino.kir.corp.google.com>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz> <1453812353-26744-9-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

On Tue, 26 Jan 2016, Vlastimil Babka wrote:

> It would be useful to translate gfp_flags into string representation when
> printing in case of an OOM, especially as the flags have been undergoing some
> changes recently and the script ./scripts/gfp-translate needs a matching source
> version to be accurate.
> 
> Example output:
> 
> a.out invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO), order=0, om_score_adj=0
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
