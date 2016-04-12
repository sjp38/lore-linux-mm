Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 58FE46B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 05:38:32 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id f198so179561793wme.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 02:38:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e18si33368741wjx.104.2016.04.12.02.38.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 02:38:31 -0700 (PDT)
Subject: Re: mmotm woes, mainly compaction
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570CC216.8030201@suse.cz>
Date: Tue, 12 Apr 2016 11:38:30 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/12/2016 09:18 AM, Hugh Dickins wrote:
> 1. Fix crash in release_pages() from compact_zone() from kcompactd_do_work():
>     kcompactd needs to INIT_LIST_HEAD on the new freepages_held list.

Hmm, right. I didn't notice the new call site added by one series when 
rebasing the other series :/

> 4. Added VM_BUG_ONs to assert freepages_held is empty, matching those on
>     the other lists - though they're getting to look rather too much now.

I think the easiest thing to do for now is to drop from mmotm:
mm-compaction-direct-freepage-allocation-for-async-direct-compaction.patch
As Mel and Joonsoo didn't like it in the current state anyway.

> 6. Remove unused bool success from kcompactd_do_work().

That leaves just this part, which didn't fit anywhere else. I guess can 
just fold it to upcoming kcompactd patches?

Thanks for organizing my morning today, Hugh :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
