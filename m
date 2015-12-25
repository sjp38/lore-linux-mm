Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB026B02F4
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 06:44:31 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p187so199106642wmp.0
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 03:44:31 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id e196si63691021wmd.100.2015.12.25.03.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 03:44:30 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id l126so200994318wml.1
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 03:44:30 -0800 (PST)
Date: Fri, 25 Dec 2015 12:44:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20151225114428.GC6754@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
 <CAOxpaSV38vy2ywCqQZggfydWsSfAOVo-q8cn7OcuN86ch=4mEA@mail.gmail.com>
 <20151224094758.GA22760@dhcp22.suse.cz>
 <CAOxpaSXRxJGqL3Fxz5280KZy6xG0ZGwyrf-7i6LArSC0eJsv2A@mail.gmail.com>
 <20151225113537.GA6754@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151225113537.GA6754@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <zwisler@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri 25-12-15 12:35:37, Michal Hocko wrote:
[...]
> Thanks I will try to reproduce early next year. But so far I think this
> is just a general issue of MADV_DONTNEED vs. truncate and oom_reaper is
> just lucky to trigger it. There shouldn't be anything oom_reaper
> specific here. Maybe there is some additional locking missing?

Hmm, scratch that. I think Tetsuo has nailed it. It seems like
the missing initialization of details structure during unmap
is the culprit. So there most probably was on OOM killing
invoked. It is just a side effect of the patch and missing
http://marc.info/?l=linux-mm&m=145068666428057 follow up fix.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
