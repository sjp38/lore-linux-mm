Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B499D6B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 19:01:20 -0500 (EST)
Received: by padhx2 with SMTP id hx2so54508999pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 16:01:20 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id f22si7822190pfd.61.2015.12.02.16.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 16:01:20 -0800 (PST)
Received: by padhx2 with SMTP id hx2so54508759pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 16:01:19 -0800 (PST)
Date: Wed, 2 Dec 2015 16:01:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm, oom: Give __GFP_NOFAIL allocations access to
 memory reserves
In-Reply-To: <1449069190-7325-1-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1512021601040.22865@chino.kir.corp.google.com>
References: <1448448054-804-2-git-send-email-mhocko@kernel.org> <1449069190-7325-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, 2 Dec 2015, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_NOFAIL is a big hammer used to ensure that the allocation
> request can never fail. This is a strong requirement and as such
> it also deserves a special treatment when the system is OOM. The
> primary problem here is that the allocation request might have
> come with some locks held and the oom victim might be blocked
> on the same locks. This is basically an OOM deadlock situation.
> 
> This patch tries to reduce the risk of such a deadlocks by giving
> __GFP_NOFAIL allocations a special treatment and let them dive into
> memory reserves after oom killer invocation. This should help them
> to make a progress and release resources they are holding. The OOM
> victim should compensate for the reserves consumption.
> 
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
