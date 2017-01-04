Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EAEDB6B0260
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 08:53:07 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id s63so83581976wms.7
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 05:53:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qp9si81446370wjc.142.2017.01.04.05.53.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 05:53:05 -0800 (PST)
Date: Wed, 4 Jan 2017 14:52:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20170104135244.GJ25453@dhcp22.suse.cz>
References: <20170104101942.4860-1-mhocko@kernel.org>
 <20170104101942.4860-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104101942.4860-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

With fixed triggered by Vlastimil it should be like this.
---
