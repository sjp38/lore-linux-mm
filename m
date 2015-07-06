Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB4D2802BF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 11:12:00 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so287875042wiw.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 08:12:00 -0700 (PDT)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com. [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id lg1si30686369wjc.136.2015.07.06.08.11.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 08:11:59 -0700 (PDT)
Received: by wguu7 with SMTP id u7so143362475wgu.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 08:11:58 -0700 (PDT)
From: Nicolai Stange <nicstange@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: deferred meminit: replace rwsem with completion
References: <87k2uecf6t.fsf@gmail.com> <20150706082143.GG6812@suse.de>
Date: Mon, 06 Jul 2015 17:11:55 +0200
In-Reply-To: <20150706082143.GG6812@suse.de> (Mel Gorman's message of "Mon, 6
	Jul 2015 09:21:43 +0100")
Message-ID: <87y4itxqv8.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nicolai Stange <nicstange@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Mel Gorman <mgorman@suse.de> writes:
> Acked-by: Mel Gorman <mgorman@suse.de>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
