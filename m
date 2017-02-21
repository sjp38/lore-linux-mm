Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 498A76B0389
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 04:44:00 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t18so14685225wmt.7
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 01:44:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k19si15742528wmi.125.2017.02.21.01.43.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Feb 2017 01:43:58 -0800 (PST)
Date: Tue, 21 Feb 2017 10:43:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 5/7] mm: add vmstat account for MADV_FREE pages
Message-ID: <20170221094353.GG15595@dhcp22.suse.cz>
References: <cover.1486163864.git.shli@fb.com>
 <d12c1b4b571817c0f05a57cc062d91d1a336fce5.1486163864.git.shli@fb.com>
 <20170210132727.GM10893@dhcp22.suse.cz>
 <20170210175015.GD86050@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210175015.GD86050@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

[Sorry for a late reply I was on vacation last week]

On Fri 10-02-17 09:50:15, Shaohua Li wrote:
> On Fri, Feb 10, 2017 at 02:27:27PM +0100, Michal Hocko wrote:
> > On Fri 03-02-17 15:33:21, Shaohua Li wrote:
> > > Show MADV_FREE pages info in proc/sysfs files.
> > 
> > How are we going to use this information? Why it isn't sufficient to
> > watch for lazyfree events? I mean this adds quite some code and it is
> > not clear (at least from the changelog) we we need this information.
> 
> It's just like any other meminfo we added to let user know what happens in the
> system. Users can use the info for monitoring/diagnosing. the
> lazyfree/lazyfreed events can't reflect the lazyfree page info because
> 'lazyfree - lazyfreed' doesn't equal current lazyfree pages and the events
> aren't per-node. I'll add more description in the changelog.

Well, I would prefer to not add new counters until there is a strong
reason for them. Maybe a trace point would be more appropriate for
debugging purposes.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
