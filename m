Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA196B0404
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 05:10:34 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so34864182wms.7
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 02:10:34 -0800 (PST)
Received: from celine.tisys.org (celine.tisys.org. [85.25.117.166])
        by mx.google.com with ESMTPS id cq10si3985697wjb.266.2016.12.22.02.10.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 02:10:32 -0800 (PST)
Date: Thu, 22 Dec 2016 11:10:29 +0100
From: Nils Holland <nholland@tisys.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161222101028.GA11105@ppc-nas.fritz.box>
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
 <20161216184655.GA5664@boerne.fritz.box>
 <20161217000203.GC23392@dhcp22.suse.cz>
 <20161217125950.GA3321@boerne.fritz.box>
 <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
 <20161217210646.GA11358@boerne.fritz.box>
 <20161219134534.GC5164@dhcp22.suse.cz>
 <20161220020829.GA5449@boerne.fritz.box>
 <20161221073658.GC16502@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161221073658.GC16502@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Wed, Dec 21, 2016 at 08:36:59AM +0100, Michal Hocko wrote:
> TL;DR
> there is another version of the debugging patch. Just revert the
> previous one and apply this one instead. It's still not clear what
> is going on but I suspect either some misaccounting or unexpeted
> pages on the LRU lists. I have added one more tracepoint, so please
> enable also mm_vmscan_inactive_list_is_low.

Right, I did just that and can provide a new log. I was also able, in
this case, to reproduce the OOM issues again and not just the "page
allocation stalls" that were the only thing visible in the previous
log. However, the log comes from machine #2 again today, as I'm
unfortunately forced to try this via VPN from work to home today, so I
have exactly one attempt per machine before it goes down and locks up
(and I can only restart it later tonight). Machine #1 failed to
produce good looking results during its one attempt, but what machine #2
produced seems to be exactly what we've been trying to track down, and so
its log us now up at:

http://ftp.tisys.org/pub/misc/boerne_2016-12-22.log.xz

Greetings
Nils

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
