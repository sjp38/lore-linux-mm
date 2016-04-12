Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D16896B025E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 07:55:01 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id n3so24779049wmn.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 04:55:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ev6si2880239wjd.58.2016.04.12.04.55.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 04:55:00 -0700 (PDT)
Subject: Re: [PATCH 09/11] mm, compaction: Abstract compaction feedback to
 helpers
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-10-git-send-email-mhocko@kernel.org>
 <20160411154036.GN23157@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570CE213.8050505@suse.cz>
Date: Tue, 12 Apr 2016 13:54:59 +0200
MIME-Version: 1.0
In-Reply-To: <20160411154036.GN23157@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 04/11/2016 05:40 PM, Michal Hocko wrote:
> Hi Andrew,
> Vlastimil has pointed out[1] that using compaction_withdrawn() for THP
> allocations has some non-trivial consequences. While I still think that
> the check is OK it is true we shouldn't sneak in a potential behavior
> change into something that basically provides an API. So can you fold
> the following partial revert into the original patch please?
>
> [1] http://lkml.kernel.org/r/570BB719.2030007@suse.cz
>
> ---
>  From 71ddeee4238e33d67ef07883e73f946a7cc40e73 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 11 Apr 2016 17:38:22 +0200
> Subject: [PATCH] ction-abstract-compaction-feedback-to-helpers-fix
>
> Preserve the original thp back off checks to not introduce any
> functional changes as per Vlastimil.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Ack, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
