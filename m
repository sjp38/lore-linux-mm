Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A1A4E6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 11:42:27 -0400 (EDT)
Received: by wgez8 with SMTP id z8so117989100wge.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 08:42:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dx2si19325909wib.2.2015.06.01.08.42.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 08:42:26 -0700 (PDT)
Date: Mon, 1 Jun 2015 17:42:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150601154225.GJ7147@dhcp22.suse.cz>
References: <20150601101646.GC7147@dhcp22.suse.cz>
 <201506012102.CBE60453.FOQtFJLFSHOOVM@I-love.SAKURA.ne.jp>
 <20150601121508.GF7147@dhcp22.suse.cz>
 <201506012204.GIF87536.LFMtOOOVJFFSQH@I-love.SAKURA.ne.jp>
 <20150601131215.GI7147@dhcp22.suse.cz>
 <201506020027.CJI18736.FJLVtFQOHMFOSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506020027.CJI18736.FJLVtFQOHMFOSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Tue 02-06-15 00:27:44, Tetsuo Handa wrote:
[...]
> I've been asking for backportable workaround for many months. I spent time for
> finding potential bugs ( http://marc.info/?l=linux-mm&m=141684929114209 ).
> If you are already aware that there are million+1 corner cases possible yet
> (that is, we have too many potential bugs to identify and fix), why do you
> keep refusing to offer for-now workaround (that is, paper over potential
> bugs) ? I don't want to see customers and support staff suffering with OOM
> corner cases any more...

For-now workarounds tend to make the code even more complex and
fragile. It is much more preferable to come up with a systematic solution
rather than a pile of workarounds. Pushing workarounds just because they
are easy to backport to distribution kernels is a wrong criteria.

The current OOM killer code is far from ideal. Some of the heuristics
might be suboptimal or even outright wrong. But piling more on them is
not a way forward.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
