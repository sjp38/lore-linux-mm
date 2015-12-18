Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id A75256B0005
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 11:36:10 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p187so71872626wmp.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 08:36:10 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f187si13302208wmd.4.2015.12.18.08.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 08:36:09 -0800 (PST)
Date: Fri, 18 Dec 2015 11:35:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20151218163553.GC4201@cmpxchg.org>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20151216155844.d1c3a5f35bc98072a80f939e@linux-foundation.org>
 <20151218131509.GH28443@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151218131509.GH28443@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 18, 2015 at 02:15:09PM +0100, Michal Hocko wrote:
> On Wed 16-12-15 15:58:44, Andrew Morton wrote:
> > It's hard to say how long declaration of oom should take.  Correctness
> > comes first.  But what is "correct"?  oom isn't a binary condition -
> > there's a chance that if we keep churning away for another 5 minutes
> > we'll be able to satisfy this allocation (but probably not the next
> > one).  There are tradeoffs between promptness-of-declaring-oom and
> > exhaustiveness-in-avoiding-it.
> 
> Yes, this is really hard to tell. What I wanted to achieve here is a
> determinism - the same load should give comparable results. It seems
> that there is an improvement in this regards. The time to settle is 
> much more consistent than with the original implementation.

+1

Before that we couldn't even really make a meaningful statement about
how long we are going to try - "as long as reclaim thinks it can maybe
do some more, depending on heuristics". I think the best thing we can
strive for with OOM is to make the rules simple and predictable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
