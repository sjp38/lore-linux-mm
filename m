Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 140D428027D
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 23:26:07 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 20so7144591ioj.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 20:26:07 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id b200si990149ioe.142.2016.09.26.20.26.04
        for <linux-mm@kvack.org>;
        Mon, 26 Sep 2016 20:26:06 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160926162025.21555-1-vbabka@suse.cz> <20160926162025.21555-2-vbabka@suse.cz>
In-Reply-To: <20160926162025.21555-2-vbabka@suse.cz>
Subject: Re: [PATCH 1/4] mm, compaction: more reliably increase direct compaction priority-fix
Date: Tue, 27 Sep 2016 11:25:46 +0800
Message-ID: <01a101d2186e$d66729c0$83357d40$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Arkadiusz Miskiewicz' <a.miskiewicz@gmail.com>, 'Ralf-Peter Rohbeck' <Ralf-Peter.Rohbeck@quantum.com>, 'Olaf Hering' <olaf@aepfle.de>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'David Rientjes' <rientjes@google.com>, 'Rik van Riel' <riel@redhat.com>, 'Michal Hocko' <mhocko@kernel.org>, 'Michal Hocko' <mhocko@suse.com>

On Tuesday, September 27, 2016 12:20 AM Vlastimil Babka wrote 
> 
> When increasing the compaction priority, also reset retries. Otherwise we can
> consume all retries on the lower priorities. Also pull the retries increment
> into should_compact_retry() so it counts only the rounds where we actually
> rely on it.
> 
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
