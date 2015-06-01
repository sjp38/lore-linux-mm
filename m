Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id DA4DF6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 09:12:18 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so38119580wib.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 06:12:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o18si24665516wjw.153.2015.06.01.06.12.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 06:12:17 -0700 (PDT)
Date: Mon, 1 Jun 2015 15:12:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150601131215.GI7147@dhcp22.suse.cz>
References: <201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
 <201505312010.JJJ26561.FJOOVSQHLFOtMF@I-love.SAKURA.ne.jp>
 <20150601101646.GC7147@dhcp22.suse.cz>
 <201506012102.CBE60453.FOQtFJLFSHOOVM@I-love.SAKURA.ne.jp>
 <20150601121508.GF7147@dhcp22.suse.cz>
 <201506012204.GIF87536.LFMtOOOVJFFSQH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506012204.GIF87536.LFMtOOOVJFFSQH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Mon 01-06-15 22:04:28, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > Likewise, move do_send_sig_info(SIGKILL, victim) to before
> > > mark_oom_victim(victim) in case for_each_process() took very long time,
> > > for the OOM victim can abuse ALLOC_NO_WATERMARKS by TIF_MEMDIE via e.g.
> > > memset() in user space until SIGKILL is delivered.
> > 
> > This is unrelated and I believe even not necessary.
> 
> Why unnecessary? If serial console is configured and printing a series of
> "Kill process %d (%s) sharing same memory" took a few seconds, the OOM
> victim can consume all memory via malloc() + memset(), can't it?

Can? You are generating one corner case after another. All of them
without actually showing it can happen in the real life. There are
million+1 corner cases possible yet we would prefer to handle those that
have changes to happen in the real life. So let's focus on the real life
scenarios.

> What to do if the OOM victim cannot die immediately after consuming
> all memory? I think that sending SIGKILL before setting TIF_MEMDIE
> helps reducing consumption of memory reserves.

I think that SIGKILL before or after mark_oom_victim has close to zero
effect. If you think that we should send SIGKILL before looking for
tasks sharing mm then why not - BUT AGAIN A SEPARATE PATCH WITH A
JUSTIFICATION please.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
