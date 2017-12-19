Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48A716B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:19:23 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id i7so7594859plt.3
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:19:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si11071897pll.350.2017.12.19.07.19.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 07:19:22 -0800 (PST)
Date: Tue, 19 Dec 2017 16:19:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [resend PATCH 0/2] fix VFS register_shrinker fixup
Message-ID: <20171219151915.GA2787@dhcp22.suse.cz>
References: <20171219132844.28354-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219132844.28354-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Aliaksei Karaliou <akaraliou.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Dohh, I have missed resend by Tetsuo http://lkml.kernel.org/r/1513596701-4518-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
(thanks for dropping me from the CC).  Al seeemed to take the patch. We
still need patch 2. Al, are you going to take it from this thread or you
are going to go your way?

On Tue 19-12-17 14:28:42, Michal Hocko wrote:
> Hi Andrew,
> Tetsuo has posted patch 1 already [1]. I had some minor concenrs about
> the changelog but the approach was already OK. Aliaksei came with an
> alternative patch [2] which also handles double unregistration. I have
> updated the changelog and moved the syzbot report to the 2nd patch
> because it is more related to the change there. The patch 1 is
> prerequisite. Maybe we should just merge those two. I've kept Tetsuo's
> s-o-b and his original authorship, but let me know if you disagree with
> the new wording or the additional change, Tetsuo.
> 
> The patch 2 is based on Al's suggestion [3] and it fixes sget_userns
> shrinker registration code.
> 
> Both of these stalled so can we have them merged finally?
> 
> [1] http://lkml.kernel.org/r/1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> [2] http://lkml.kernel.org/r/20171216192937.13549-1-akaraliou.dev@gmail.com
> [3] http://lkml.kernel.org/r/20171123145540.GB21978@ZenIV.linux.org.uk

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
