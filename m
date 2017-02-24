Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 168C96B0038
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 11:57:03 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 89so13868849wrr.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:57:03 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p198si1542732wmd.96.2017.02.24.08.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 08:57:01 -0800 (PST)
Date: Fri, 24 Feb 2017 11:51:05 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm/vmscan: fix high cpu usage of kswapd if there are
 no reclaimable pages
Message-ID: <20170224165105.GB20092@cmpxchg.org>
References: <1487918992-7515-1-git-send-email-hejianet@gmail.com>
 <20170224084949.GA19161@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170224084949.GA19161@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jia He <hejianet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Fri, Feb 24, 2017 at 09:49:50AM +0100, Michal Hocko wrote:
> I believe we should pursue the proposal from Johannes which is more
> generic and copes with corner cases much better.

Jia, can you try this? I'll put the cleanups in follow-up patches.

---
