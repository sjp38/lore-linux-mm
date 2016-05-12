Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0CA36B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 02:16:39 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ne4so6576404lbc.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 23:16:39 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id jf6si6820413wjb.6.2016.05.11.23.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 23:16:38 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e201so13687368wme.2
        for <linux-mm@kvack.org>; Wed, 11 May 2016 23:16:38 -0700 (PDT)
Date: Thu, 12 May 2016 08:16:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, compaction: avoid uninitialized variable use
Message-ID: <20160512061636.GA4200@dhcp22.suse.cz>
References: <1462973126-1183468-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462973126-1183468-1-git-send-email-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I think this would be slightly better than your proposal. Andrew, could
you fold it into the original
mm-compaction-simplify-__alloc_pages_direct_compact-feedback-interface.patch
patch?
---
