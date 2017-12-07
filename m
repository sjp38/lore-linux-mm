Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE2386B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 11:25:28 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e70so3630042wmc.6
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 08:25:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p13si4100182wre.321.2017.12.07.08.25.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 08:25:27 -0800 (PST)
Date: Thu, 7 Dec 2017 17:25:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
Message-ID: <20171207162525.GL20234@dhcp22.suse.cz>
References: <20171206192026.25133-1-surenb@google.com>
 <20171207095223.GB574@jagdpanzerIV>
 <20171207095835.GE20234@dhcp22.suse.cz>
 <CAJuCfpEqReQBLXWX9mG9fm9wgMr_4WMHfxHe8GgG-1+sYuPkXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpEqReQBLXWX9mG9fm9wgMr_4WMHfxHe8GgG-1+sYuPkXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>, Todd Kjos <tkjos@google.com>

On Thu 07-12-17 07:46:07, Suren Baghdasaryan wrote:
> I'm, terribly sorry. My original code was checking for additional
> condition which I realized is not useful here because it would mean
> the signal was already processed. Should have missed the error while
> removing it. Will address Michal's comments and fix the problem.

yes, rebasing at last moment tend to screw things... No worries, I would
be more worried about the general approach here and its documentataion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
