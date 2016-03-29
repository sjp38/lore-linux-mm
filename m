Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id AFDC46B0253
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 10:14:45 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id p65so28488608wmp.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 07:14:45 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id s18si12098078wmd.36.2016.03.29.07.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 07:14:44 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id p65so28488070wmp.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 07:14:44 -0700 (PDT)
Date: Tue, 29 Mar 2016 16:14:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
Message-ID: <20160329141442.GD4466@dhcp22.suse.cz>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 29-03-16 15:27:35, Michal Hocko wrote:
[...]
> If this looks like a reasonable approach I would go on think about how
> we can extend this for the oom_reaper and queue the current thread for
> the reaper to free some of the memory.

And this is what I came up with (untested yet). Doesn't too bad to me:
---
