Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 86CBE6B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 18:27:41 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so133955263pab.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 15:27:41 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id uu9si2197517pac.19.2015.11.20.15.27.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 15:27:40 -0800 (PST)
Received: by pacej9 with SMTP id ej9so129954290pac.2
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 15:27:40 -0800 (PST)
Date: Fri, 20 Nov 2015 15:27:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
In-Reply-To: <20151120090626.GB16698@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1511201523520.10092@chino.kir.corp.google.com>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org> <1447851840-15640-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1511191455310.17510@chino.kir.corp.google.com> <20151120090626.GB16698@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, 20 Nov 2015, Michal Hocko wrote:

> > > +		unsigned long reclaimable;
> > > +		unsigned long target;
> > > +
> > > +		reclaimable = zone_reclaimable_pages(zone) +
> > > +			      zone_page_state(zone, NR_ISOLATED_FILE) +
> > > +			      zone_page_state(zone, NR_ISOLATED_ANON);
> > 
> > Does NR_ISOLATED_ANON mean anything relevant here in swapless 
> > environments?
> 
> It should be 0 so I didn't bother to check for swapless configuration.
> 

I'm not sure I understand your point, memory compaction certainly 
increments NR_ISOLATED_ANON and that would be considered unreclaimable in 
a swapless environment, correct?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
