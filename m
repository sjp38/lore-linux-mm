Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3CF6B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 10:55:40 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so55197057wmu.1
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 07:55:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hi2si50376137wjc.63.2016.12.27.07.55.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Dec 2016 07:55:38 -0800 (PST)
Date: Tue, 27 Dec 2016 16:55:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161227155532.GI1308@dhcp22.suse.cz>
References: <20161221073658.GC16502@dhcp22.suse.cz>
 <20161222101028.GA11105@ppc-nas.fritz.box>
 <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
 <20161223222559.GA5568@teela.multi.box>
 <20161226124839.GB20715@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161226124839.GB20715@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

Hi,
could you try to run with the following patch on top of the previous
one? I do not think it will make a large change in your workload but
I think we need something like that so some testing under which is known
to make a high lowmem pressure would be really appreciated. If you have
more time to play with it then running with and without the patch with
mm_vmscan_direct_reclaim_{start,end} tracepoints enabled could tell us
whether it make any difference at all.

I would also appreciate if Mel and Johannes had a look at it. I am not
yet sure whether we need the same thing for anon/file balancing in
get_scan_count. I suspect we need but need to think more about that.

Thanks a lot again!
---
