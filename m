Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 336596B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 11:09:58 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id i129so2060483ioi.1
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:09:58 -0800 (PST)
Received: from resqmta-po-05v.sys.comcast.net (resqmta-po-05v.sys.comcast.net. [2001:558:fe16:19:96:114:154:164])
        by mx.google.com with ESMTPS id z207si13031646itc.173.2018.02.21.08.09.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 08:09:57 -0800 (PST)
Date: Wed, 21 Feb 2018 10:09:53 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 0/3] Directed kmem charging
In-Reply-To: <20180221030101.221206-1-shakeelb@google.com>
Message-ID: <alpine.DEB.2.20.1802211002200.12567@nuc-kabylake>
References: <20180221030101.221206-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Another way to solve this is to switch the user context right?

Isnt it possible to avoid these patches if do the allocation in another
task context instead?

Are there really any other use cases beyond fsnotify?


The charging of the memory works on a per page level but the allocation
occur from the same page for multiple tasks that may be running on a
system. So how relevant is this for other small objects?

Seems that if you do a large amount of allocations for the same purpose
your chance of accounting it to the right memcg increases. But this is a
game of chance.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
