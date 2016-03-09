Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id E89546B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 10:52:41 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p65so198429143wmp.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 07:52:41 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id d62si11311228wmf.64.2016.03.09.07.52.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 07:52:40 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id 1so10912119wmg.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 07:52:40 -0800 (PST)
Date: Wed, 9 Mar 2016 16:52:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/5] introduce kcompactd and stop compacting in kswapd
Message-ID: <20160309155238.GK27018@dhcp22.suse.cz>
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 08-02-16 14:38:06, Vlastimil Babka wrote:
> The previous RFC is here [1]. It didn't have a cover letter, so the description
> and results are in the individual patches.

FWIW I think this is a step in the right direction. I would give my
Acked-by to all patches but I wasn't able to find time for a deep review
and my lack of knowledge of compaction details doesn't help much. I do
agree that conflating kswapd with compaction didn't really work out well
and fixing this would just make the code more complex and would more
prone to new bugs. In future we might want to invent something similar
to watermarks and set an expected level of high order pages prepared for
the allocation (e.g. have at least XMB of memory in order-9+). kcompact
then could try as hard as possible to provide them. Does that sound at
least doable?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
