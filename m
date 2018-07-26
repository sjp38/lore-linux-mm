Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB0C6B026C
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 03:44:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j14-v6so469751edr.2
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:44:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g3-v6si823367edg.360.2018.07.26.00.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 00:44:32 -0700 (PDT)
Date: Thu, 26 Jul 2018 09:44:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
Message-ID: <20180726074430.GV28386@dhcp22.suse.cz>
References: <2018072514375722198958@wingtech.com>
 <20180725141643.6d9ba86a9698bc2580836618@linux-foundation.org>
 <2018072610214038358990@wingtech.com>
 <20180726060640.GQ28386@dhcp22.suse.cz>
 <20180726150323057627100@wingtech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726150323057627100@wingtech.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Cc: akpm <akpm@linux-foundation.org>, mgorman <mgorman@techsingularity.net>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Thu 26-07-18 15:03:23, zhaowuyun@wingtech.com wrote:
> >On Thu 26-07-18 10:21:40, zhaowuyun@wingtech.com wrote:
> >[...]
> >> Our project really needs a fix to this issue
> >
> >Could you be more specific why? My understanding is that RT tasks
> >usually have all the memory mlocked otherwise all the real time
> >expectations are gone already.
> >--
> >Michal Hocko
> >SUSE Labs 
> 
> 
> The RT thread is created by a process with normal priority, and the process was sleep, 
> then some task needs the RT thread to do something, so the process create this thread, and set it to RT policy.
> I think that is the reason why RT task would read the swap.

OK I see. This design is quite fragile though. You are opening ticket to
priority inversions and what not.

Anyway, the underlying swap issue should be fixed. Unfortunatelly I do
not have a great idea how to do that properly.

-- 
Michal Hocko
SUSE Labs
