Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BDEBB6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 17:33:53 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 128so30156663wmz.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:33:53 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id o123si6914266wmd.53.2016.01.28.14.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 14:33:52 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id 128so4311005wmz.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:33:52 -0800 (PST)
Date: Thu, 28 Jan 2016 23:33:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/2] oom: clear TIF_MEMDIE after oom_reaper managed to
 unmap the address space
Message-ID: <20160128223351.GA14803@dhcp22.suse.cz>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
 <1452516120-5535-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452516120-5535-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

I have missed one important point. exit_oom_victim has to do
test_and_clear to make sure we do not race now with this patch. So we
need to fold the following into the patch
---
