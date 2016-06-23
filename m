Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5127828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:26:51 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id c1so56156627lbw.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 03:26:51 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id j10si6401784wjz.100.2016.06.23.03.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 03:26:50 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id E72D61C1963
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 11:26:49 +0100 (IST)
Date: Thu, 23 Jun 2016 11:26:48 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/27] Move LRU page reclaim from zones to nodes v7
Message-ID: <20160623102648.GP1868@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 21, 2016 at 03:15:39PM +0100, Mel Gorman wrote:
> The bulk of the updates are in response to review from Vlastimil Babka
> and received a lot more testing than v6.
> 

Hi Andrew,

Please drop these patches again from mmotm.

There has been a number of odd conflicts resulting in at least one major
bug where a node-counter is used on a zone that will result in random
behaviour. Some of the additional feedback is non-trivial and all of it
will need to be resolved against the OOM detection rework and the huge
tmpfs implementation.

It'll take time to resolve this and I don't want to leave mmotm in a
broken state in the meantime. I have a copy of mmots so I have the conflict
resolutions you already applied.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
