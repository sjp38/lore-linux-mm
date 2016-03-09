Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 584A46B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 22:55:34 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id td3so1757835pab.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 19:55:34 -0800 (PST)
Received: from out4133-130.mail.aliyun.com (out4133-130.mail.aliyun.com. [42.120.133.130])
        by mx.google.com with ESMTP id bs10si9271480pad.73.2016.03.08.19.55.29
        for <linux-mm@kvack.org>;
        Tue, 08 Mar 2016 19:55:33 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160307160838.GB5028@dhcp22.suse.cz> <1457444565-10524-1-git-send-email-mhocko@kernel.org> <1457444565-10524-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1457444565-10524-2-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, compaction: change COMPACT_ constants into enum
Date: Wed, 09 Mar 2016 11:55:20 +0800
Message-ID: <059d01d179b7$807f7db0$817e7910$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Hugh Dickins' <hughd@google.com>, 'Sergey Senozhatsky' <sergey.senozhatsky.work@gmail.com>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Joonsoo Kim' <js1304@gmail.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

> 
> From: Michal Hocko <mhocko@suse.com>
> 
> compaction code is doing weird dances between
> COMPACT_FOO -> int -> unsigned long
> 
> but there doesn't seem to be any reason for that. All functions which
> return/use one of those constants are not expecting any other value
> so it really makes sense to define an enum for them and make it clear
> that no other values are expected.
> 
> This is a pure cleanup and shouldn't introduce any functional changes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
