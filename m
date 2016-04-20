Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id D5FA16B026B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 14:05:48 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id o131so120860403ywc.2
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 11:05:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v39si738868qge.105.2016.04.20.11.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 11:05:48 -0700 (PDT)
Message-ID: <1461175544.3200.20.camel@redhat.com>
Subject: Re: [PATCH 4.6] mm: wake kcompactd before kswapd's short sleep
From: Rik van Riel <riel@redhat.com>
Date: Wed, 20 Apr 2016 14:05:44 -0400
In-Reply-To: <1461098191-29304-1-git-send-email-vbabka@suse.cz>
References: <1461098191-29304-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 2016-04-19 at 22:36 +0200, Vlastimil Babka wrote:
> When kswapd goes to sleep it checks if the node is balanced and at
> first it
> sleeps only for HZ/10 time, then rechecks if the node is still
> balanced and
> nobody has woken it during the initial sleep. Only then it goes fully
> sleep
> until an allocation slowpath wakes it up again.
> 

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
