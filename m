Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6B46B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 04:41:49 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 5so453027wrz.14
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 01:41:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f18si6797740wrc.302.2017.08.15.01.41.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 01:41:48 -0700 (PDT)
Date: Tue, 15 Aug 2017 10:41:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170815084143.GB29067@dhcp22.suse.cz>
References: <201708120046.AFI81780.OHMFtFSOFVQJOL@I-love.SAKURA.ne.jp>
 <20170814135919.GO19063@dhcp22.suse.cz>
 <201708142251.v7EMp3j9081456@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708142251.v7EMp3j9081456@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 15-08-17 07:51:02, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > Were you able to reproduce with other filesystems?
> 
> Yes, I can reproduce this problem using both xfs and ext4 on 4.11.11-200.fc25.x86_64
> on Oracle VM VirtualBox on Windows.

Just a quick question.
http://lkml.kernel.org/r/201708112053.FIG52141.tHJSOQFLOFMFOV@I-love.SAKURA.ne.jp
mentioned next-20170811 kernel and this one 4.11. Your original report
as a reply to this thread
http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp
mentioned next-20170728. None of them seem to have this fix
http://lkml.kernel.org/r/20170807113839.16695-3-mhocko@kernel.org so let
me ask again. Have you seen an unexpected content written with that
patch applied?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
