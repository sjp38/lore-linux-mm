Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B55D46B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 09:02:36 -0500 (EST)
Received: by wghk14 with SMTP id k14so3842188wgh.4
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 06:02:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10si29209913wiv.79.2015.02.25.06.02.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 06:02:34 -0800 (PST)
Date: Wed, 25 Feb 2015 15:02:31 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, oom: do not fail __GFP_NOFAIL allocation if oom
 killer is disbaled
Message-ID: <20150225140231.GC26680@dhcp22.suse.cz>
References: <1424801964-1602-1-git-send-email-mhocko@suse.cz>
 <20150224191127.GA14718@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150224191127.GA14718@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 24-02-15 14:11:27, Johannes Weiner wrote:
[...]
> I'm fine with keeping the allocation looping, but is that message
> helpful?  It seems completely useless to the user encountering it.  Is
> it going to help kernel developers when we get a bug report with it?

It is better than a silent endless loop. And we get a trace which points
to the place which is doing the allocation. We haven't seen any weird
crashes during suspend throughout last 6 years so this would be
extremely unlikely and hard to reproduce so having the trace sounds
useful to me.

> WARN_ON_ONCE()?

I do not expect this will spew a lot of messages. But I can live with
WARN_ON_ONCE as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
