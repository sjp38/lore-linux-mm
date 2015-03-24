Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id A485B6B006E
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:40:06 -0400 (EDT)
Received: by qgez102 with SMTP id z102so109917692qge.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:40:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e79si4112327qhc.129.2015.03.24.07.40.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 07:40:03 -0700 (PDT)
Message-ID: <5511773B.6020103@redhat.com>
Date: Tue, 24 Mar 2015 10:39:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Remove usages of ACCESS_ONCE
References: <1427150680.2515.36.camel@j-VirtualBox>
In-Reply-To: <1427150680.2515.36.camel@j-VirtualBox>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Low <jason.low2@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Davidlohr Bueso <dave@stgolabs.net>

On 03/23/2015 06:44 PM, Jason Low wrote:
> Commit 38c5ce936a08 converted ACCESS_ONCE usage in gup_pmd_range() to
> READ_ONCE, since ACCESS_ONCE doesn't work reliably on non-scalar types.
> 
> This patch removes the rest of the usages of ACCESS_ONCE, and use
> READ_ONCE for the read accesses. This also makes things cleaner,
> instead of using separate/multiple sets of APIs.
> 
> Signed-off-by: Jason Low <jason.low2@hp.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
