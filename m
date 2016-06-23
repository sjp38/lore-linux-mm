Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03E57828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 07:27:17 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id nq2so57622453lbc.3
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:27:16 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id e20si5941995wma.7.2016.06.23.04.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 04:27:15 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id a66so45422863wme.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:27:15 -0700 (PDT)
Date: Thu, 23 Jun 2016 13:27:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 00/27] Move LRU page reclaim from zones to nodes v7
Message-ID: <20160623112714.GF30077@dhcp22.suse.cz>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <20160623102648.GP1868@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160623102648.GP1868@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 23-06-16 11:26:48, Mel Gorman wrote:
> On Tue, Jun 21, 2016 at 03:15:39PM +0100, Mel Gorman wrote:
> > The bulk of the updates are in response to review from Vlastimil Babka
> > and received a lot more testing than v6.
> > 
> 
> Hi Andrew,
> 
> Please drop these patches again from mmotm.
> 
> There has been a number of odd conflicts resulting in at least one major
> bug where a node-counter is used on a zone that will result in random
> behaviour. Some of the additional feedback is non-trivial and all of it
> will need to be resolved against the OOM detection rework and the huge
> tmpfs implementation.

FWIW I haven't spotted any obvious misbehaving wrt. the OOM detection
rework. You have kept the per-zone counters which are used for the retry
logic so I think we should be safe. I am still reading through the
series though.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
