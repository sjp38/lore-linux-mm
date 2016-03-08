Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 70B2B6B0259
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 09:19:20 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n186so133826549wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 06:19:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j76si6342323wmj.21.2016.03.08.06.19.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 06:19:19 -0800 (PST)
Subject: Re: [PATCH 1/3] mm, compaction: change COMPACT_ constants into enum
References: <20160307160838.GB5028@dhcp22.suse.cz>
 <1457444565-10524-1-git-send-email-mhocko@kernel.org>
 <1457444565-10524-2-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DEDF63.7010509@suse.cz>
Date: Tue, 8 Mar 2016 15:19:15 +0100
MIME-Version: 1.0
In-Reply-To: <1457444565-10524-2-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 03/08/2016 02:42 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> compaction code is doing weird dances between
> COMPACT_FOO -> int -> unsigned long
> 
> but there doesn't seem to be any reason for that. All functions which

I vaguely recall trying this once and running into header dependency
hell. But maybe it was something a bit different and involved storing a
value in struct compact_control.

> return/use one of those constants are not expecting any other value
> so it really makes sense to define an enum for them and make it clear
> that no other values are expected.
> 
> This is a pure cleanup and shouldn't introduce any functional changes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
