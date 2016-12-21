Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB9BB6B03A7
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 09:04:07 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 26so221142459pgy.6
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 06:04:07 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id j13si26751910pgn.187.2016.12.21.06.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 06:04:06 -0800 (PST)
Date: Wed, 21 Dec 2016 09:04:14 -0500
From: Chris Mason <clm@fb.com>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161221140413.GA91507@clm-mbp.masoncoding.com>
References: <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
 <20161217210646.GA11358@boerne.fritz.box>
 <20161219134534.GC5164@dhcp22.suse.cz>
 <20161220020829.GA5449@boerne.fritz.box>
 <20161221073658.GC16502@dhcp22.suse.cz>
 <201612212000.EJJ21327.SFHOLQOtVFMOFJ@I-love.SAKURA.ne.jp>
 <20161221111653.GF31118@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Disposition: inline
In-Reply-To: <20161221111653.GF31118@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, nholland@tisys.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dsterba@suse.cz, linux-btrfs@vger.kernel.org

On Wed, Dec 21, 2016 at 12:16:53PM +0100, Michal Hocko wrote:
>On Wed 21-12-16 20:00:38, Tetsuo Handa wrote:
>
>One thing to note here, when we are talking about 32b kernel, things
>have changed in 4.8 when we moved from the zone based to node based
>reclaim (see b2e18757f2c9 ("mm, vmscan: begin reclaiming pages on a
>per-node basis") and associated patches). It is possible that the
>reporter is hitting some pathological path which needs fixing but it
>might be also related to something else. So I am rather not trying to
>blame 32b yet...

It might be interesting to put tracing on releasepage and see if btrfs 
is pinning pages around.  I can't see how 32bit kernels would be 
different, but maybe we're hitting a weird corner.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
