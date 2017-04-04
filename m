Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE926B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 18:07:06 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e126so33567310pfg.3
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 15:07:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 31si18687902plk.154.2017.04.04.15.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 15:07:05 -0700 (PDT)
Date: Tue, 4 Apr 2017 15:07:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: fix IO/refault regression in cache
 workingset transition
Message-Id: <20170404150703.742c49d73921df6369ed3dbd@linux-foundation.org>
In-Reply-To: <20170404220052.27593-1-hannes@cmpxchg.org>
References: <20170404220052.27593-1-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue,  4 Apr 2017 18:00:52 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Since 59dc76b0d4df ("mm: vmscan: reduce size of inactive file list")
> we noticed bigger IO spikes during changes in cache access patterns.
> 
> The patch in question shrunk the inactive list size to leave more room
> for the current workingset in the presence of streaming IO. However,
> workingset transitions that previously happened on the inactive list
> are now pushed out of memory and incur more refaults to complete.
> 
> This patch disables active list protection when refaults are being
> observed. This accelerates workingset transitions, and allows more of
> the new set to establish itself from memory, without eating into the
> ability to protect the established workingset during stable periods.
> 
> Fixes: 59dc76b0d4df ("mm: vmscan: reduce size of inactive file list")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@vger.kernel.org> # 4.7+

That's a pretty large patch and the problem has been there for a year. 
I'm not sure that it's 4.11 material, let alone -stable.  Care to
explain further?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
