Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id EAF7E6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:52:04 -0500 (EST)
Received: by wmuu63 with SMTP id u63so141149292wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:52:04 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id p190si6322783wmg.80.2015.11.25.06.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 06:52:03 -0800 (PST)
Received: by wmww144 with SMTP id w144so72508727wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:52:03 -0800 (PST)
Date: Wed, 25 Nov 2015 15:52:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/9] mm, page_owner: convert page_owner_inited to
 static key
Message-ID: <20151125145202.GL27283@dhcp22.suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448368581-6923-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Tue 24-11-15 13:36:15, Vlastimil Babka wrote:
> CONFIG_PAGE_OWNER attempts to impose negligible runtime overhead when enabled
> during compilation, but not actually enabled during runtime by boot param
> page_owner=on. This overhead can be further reduced using the static key
> mechanism, which this patch does.

Is this really worth doing? If we do not have jump labels then the check
will be atomic rather than a simple access, so it would be more costly,
no? Or am I missing something?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
