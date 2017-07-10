Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 969B244084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:58:08 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id r30so51517233qtc.5
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 06:58:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z17si10622749qkb.21.2017.07.10.06.58.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 06:58:07 -0700 (PDT)
Message-ID: <1499695083.6130.38.camel@redhat.com>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Rik van Riel <riel@redhat.com>
Date: Mon, 10 Jul 2017 09:58:03 -0400
In-Reply-To: <20170710074842.23175-1-mhocko@kernel.org>
References: <20170710074842.23175-1-mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 2017-07-10 at 09:48 +0200, Michal Hocko wrote:

> Johannes and Rik had some concerns that this could lead to premature
> OOM kills. I agree with them that we need a better throttling
> mechanism. Until now we didn't give the issue described above a high
> priority because it usually required a really insane workload to
> trigger. But it seems that the issue can be reproduced also without
> having an insane number of competing threads [3].

My worries stand, but lets fix the real observed bug, and not worry
too much about the theoretical bug for now.

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
