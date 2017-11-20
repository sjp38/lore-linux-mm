Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB926B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 05:41:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id l19so9240796pgo.4
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 02:41:43 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h12si8637602pfi.247.2017.11.20.02.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 02:41:41 -0800 (PST)
Date: Mon, 20 Nov 2017 02:41:29 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171120104129.GA25042@infradead.org>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171117173521.GA21692@infradead.org>
 <20171120092526.llj2q3lqbbxwn4g4@dhcp22.suse.cz>
 <20171120093309.GA19627@infradead.org>
 <20171120094237.z6h3kx3ne5ld64pl@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171120094237.z6h3kx3ne5ld64pl@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, Nov 20, 2017 at 10:42:37AM +0100, Michal Hocko wrote:
> The patch has been dropped because allnoconfig failed to compile back
> then http://lkml.kernel.org/r/CAP=VYLr0rPWi1aeuk4w1On9CYRNmnEWwJgGtaX=wEvGaBURtrg@mail.gmail.com
> I have problem to find the follow up discussion though. The main
> argument was that SRC is not generally available and so the core
> kernel should rely on it.

Paul,

isthere any good reason to not use SRCU in the core kernel and
instead try to reimplement it using atomic counters?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
