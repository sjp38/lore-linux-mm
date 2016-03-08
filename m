Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id AD5436B025A
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 09:22:14 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l68so152060291wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 06:22:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v131si4714296wme.78.2016.03.08.06.22.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 06:22:13 -0800 (PST)
Subject: Re: [PATCH 2/3] mm, compaction: cover all compaction mode in
 compact_zone
References: <20160307160838.GB5028@dhcp22.suse.cz>
 <1457444565-10524-1-git-send-email-mhocko@kernel.org>
 <1457444565-10524-3-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DEE014.4050409@suse.cz>
Date: Tue, 8 Mar 2016 15:22:12 +0100
MIME-Version: 1.0
In-Reply-To: <1457444565-10524-3-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 03/08/2016 02:42 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> the compiler is complaining after "mm, compaction: change COMPACT_
> constants into enum"

Potentially a squash into that patch then?

> mm/compaction.c: In function a??compact_zonea??:
> mm/compaction.c:1350:2: warning: enumeration value a??COMPACT_DEFERREDa?? not handled in switch [-Wswitch]
>   switch (ret) {
>   ^
> mm/compaction.c:1350:2: warning: enumeration value a??COMPACT_COMPLETEa?? not handled in switch [-Wswitch]
> mm/compaction.c:1350:2: warning: enumeration value a??COMPACT_NO_SUITABLE_PAGEa?? not handled in switch [-Wswitch]
> mm/compaction.c:1350:2: warning: enumeration value a??COMPACT_NOT_SUITABLE_ZONEa?? not handled in switch [-Wswitch]
> mm/compaction.c:1350:2: warning: enumeration value a??COMPACT_CONTENDEDa?? not handled in switch [-Wswitch]
> 
> compaction_suitable is allowed to return only COMPACT_PARTIAL,
> COMPACT_SKIPPED and COMPACT_CONTINUE so other cases are simply
> impossible. Put a VM_BUG_ON to catch an impossible return value.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
