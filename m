Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id ACE586B0006
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 07:12:50 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l126so62557349wml.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:12:50 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id 141si11737900wmx.30.2015.12.18.04.12.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 04:12:49 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id l126so63022542wml.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:12:49 -0800 (PST)
Date: Fri, 18 Dec 2015 13:12:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20151218121248.GG28443@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20151216153513.e432dc70e035e5d07984710c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151216153513.e432dc70e035e5d07984710c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 16-12-15 15:35:13, Andrew Morton wrote:
[...]
> So...  please have a think about it?  What can we add in here to make it
> as easy as possible for us (ie: you ;)) to get this code working well? 
> At this time, too much developer support code will be better than too
> little.  We can take it out later on.

Sure. I will think about this and get back to it early next year. I will
be mostly offline starting next week.

Thanks for looking into this!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
