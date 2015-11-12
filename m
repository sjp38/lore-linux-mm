Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9A16B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 07:44:10 -0500 (EST)
Received: by wmww144 with SMTP id w144so86683222wmw.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 04:44:09 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id 77si21790570wme.5.2015.11.12.04.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 04:44:09 -0800 (PST)
Received: by wmvv187 with SMTP id v187so31001738wmv.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 04:44:08 -0800 (PST)
Date: Thu, 12 Nov 2015 13:44:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: RFC: OOM detection rework v1
Message-ID: <20151112124407.GI1174@dhcp22.suse.cz>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

Just a heads up. I plan to repost this with changes reflecting the
feedback so far after merge window closes. There were only few minor
style fixes and one bug fixe (GFP_NOFAIL vs. costly high order
allocations). I know people are busy with the merge window now and
I hope that the future post will be a better basis for further
discussion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
