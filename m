Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1266B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 02:41:26 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so8635894wml.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 23:41:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gg9si2606416wjb.115.2016.03.03.23.41.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 23:41:25 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160229203502.GW16930@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
 <20160301133846.GF9461@dhcp22.suse.cz>
 <alpine.LSU.2.11.1603030039430.23352@eggly.anvils>
 <20160303123258.GE26202@dhcp22.suse.cz>
 <alpine.LSU.2.11.1603031244430.24359@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D93C21.9080308@suse.cz>
Date: Fri, 4 Mar 2016 08:41:21 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1603031244430.24359@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 03/03/2016 09:57 PM, Hugh Dickins wrote:
> 
>>
>> I do not have an explanation why it would cause oom sooner but this
>> turned out to be incomplete. There is another wmaark check deeper in the
>> compaction path. Could you try the one from
>> http://lkml.kernel.org/r/20160302130022.GG26686@dhcp22.suse.cz
> 
> I've now added that in: it corrects the "sooner", but does not make
> any difference to the fact of OOMing for me.

Could you try producing a trace with
echo 1 > /debug/tracing/events/compaction/enable
echo 1 > /debug/tracing/events/migrate/mm_migrate_pages/enable

Hopefully it will hint at what's wrong with:
compact_migrate_scanned 424920
compact_free_scanned 9278408
compact_isolated 469472
compact_stall 377
compact_fail 297
compact_success 80
compact_kcompatd_wake 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
