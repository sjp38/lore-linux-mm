Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D6BC66B026B
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:59:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c20-v6so1042940eds.21
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:59:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18-v6si313018edl.68.2018.07.03.07.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:59:37 -0700 (PDT)
Date: Tue, 3 Jul 2018 16:59:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm,oom: Bring OOM notifier to outside of oom_lock.
Message-ID: <20180703145936.GO16767@dhcp22.suse.cz>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1530627910-3415-6-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530627910-3415-6-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue 03-07-18 23:25:06, Tetsuo Handa wrote:
> Since blocking_notifier_call_chain() in out_of_memory() might sleep,
> sleeping with oom_lock held is currently an unavoidable problem.

This is wrong. The problem is avoidable by simply removing the oom
notifiers as they are pure ugliness which we should have never allowed
to live in the first place.
-- 
Michal Hocko
SUSE Labs
