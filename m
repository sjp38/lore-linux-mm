Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 68B306B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 07:59:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a77so9495048wma.12
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 04:59:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 33si4995089wrr.268.2017.06.01.04.59.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 04:59:40 -0700 (PDT)
Date: Thu, 1 Jun 2017 13:59:36 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170601115936.GA9091@dhcp22.suse.cz>
References: <1496317427-5640-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496317427-5640-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> Cong Wang has reported a lockup when running LTP memcg_stress test [1].

This seems to be on an old and not pristine kernel. Does it happen also
on the vanilla up-to-date kernel?

[...]
> Therefore, this patch uses a mutex dedicated for warn_alloc() like
> suggested in [3].

As I've said previously. We have rate limiting and if that doesn't work
out well, let's tune it. The lock should be the last resort to go with.
We already throttle show_mem, maybe we can throttle dump_stack as well,
although it sounds a bit strange that this adds so much to the picture.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
