Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF706B0275
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 05:30:45 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id n3so59379579wjy.6
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:30:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u184si77257768wmb.168.2017.01.04.02.30.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 02:30:44 -0800 (PST)
Date: Wed, 4 Jan 2017 11:30:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/7 v2] vm, vmscan: enahance vmscan tracepoints
Message-ID: <20170104103040.GE25453@dhcp22.suse.cz>
References: <20170104101942.4860-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104101942.4860-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 04-01-17 11:19:35, Michal Hocko wrote:
> Hi,
> this is the second version of the patchset [1]. I hope I've addressed all
> the review feedback.

I forgot to mention that this is based on the latest mmotm +
http://lkml.kernel.org/r/20161220130135.15719-1-mhocko@kernel.org which
are sitting in the mm tree but haven't been released as a mmmotm yet.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
