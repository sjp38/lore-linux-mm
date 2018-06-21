Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1B716B0007
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 03:31:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b5-v6so1151367pfi.5
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 00:31:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4-v6si4222646plo.226.2018.06.21.00.31.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 00:31:45 -0700 (PDT)
Date: Thu, 21 Jun 2018 09:31:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Message-ID: <20180621073142.GA10465@dhcp22.suse.cz>
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed 20-06-18 15:36:45, David Rientjes wrote:
[...]
> That makes me think that "oom_notify_list" isn't very intuitive: it can 
> free memory as a last step prior to oom kill.  OOM notify, to me, sounds 
> like its only notifying some callbacks about the condition.  Maybe 
> oom_reclaim_list and then rename this to oom_reclaim_pages()?

Yes agreed and that is the reason I keep saying we want to get rid of
this yet-another-reclaim mechanism. We already have shrinkers which are
the main source of non-lru pages reclaim. Why do we even need
oom_reclaim_pages? What is fundamentally different here? Sure those
pages should be reclaimed as the last resort but we already do have
priority for slab shrinking so we know that the system is struggling
when reaching the lowest priority. Isn't that enough to express the need
for current oom notifier implementations?
-- 
Michal Hocko
SUSE Labs
