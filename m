Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16E6F6B0729
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 04:32:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q50so4985887wrb.14
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 01:32:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j19si3163268wrd.108.2017.08.04.01.32.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 01:32:06 -0700 (PDT)
Date: Fri, 4 Aug 2017 10:32:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [PATCH] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170804083205.GH26029@dhcp22.suse.cz>
References: <201708040646.v746kkhC024636@www262.sakura.ne.jp>
 <20170804074212.GA26029@dhcp22.suse.cz>
 <201708040825.v748Pkul053862@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708040825.v748Pkul053862@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 04-08-17 17:25:46, Tetsuo Handa wrote:
> Well, while lockdep warning is gone, this problem is remaining.

Ohh, I should have been more specific. Both patches have to be applied.
I have based this one first because it should go to stable. The later
one needs a trivial conflict resolution. I will send both of them as a
reply to this email!

Thanks for retesting. It matches my testing results.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
