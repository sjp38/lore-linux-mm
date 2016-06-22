Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id A79F26B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 08:15:54 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id c1so39927554lbw.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 05:15:54 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id z188si457178wmd.17.2016.06.22.05.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 05:15:53 -0700 (PDT)
Received: by mail-wm0-f48.google.com with SMTP id v199so84981739wmv.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 05:15:53 -0700 (PDT)
Date: Wed, 22 Jun 2016 14:15:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, oom_reaper: How to handle race with oom_killer_disable() ?
Message-ID: <20160622121551.GF9208@dhcp22.suse.cz>
References: <201606220032.EGD09344.VOSQOMFJOLHtFF@I-love.SAKURA.ne.jp>
 <20160621174617.GA27527@dhcp22.suse.cz>
 <201606220647.GGD48936.LMtJVOOOFFQFHS@I-love.SAKURA.ne.jp>
 <20160622064015.GB7520@dhcp22.suse.cz>
 <20160622065016.GD7520@dhcp22.suse.cz>
 <201606221957.DBC18723.LOFQSMHVJOFFOt@I-love.SAKURA.ne.jp>
 <20160622120843.GE9208@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160622120843.GE9208@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 22-06-16 14:08:43, Michal Hocko wrote:
> On Wed 22-06-16 19:57:17, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > That being said I guess the patch to try_to_freeze_tasks after
> > > oom_killer_disable should be simple enough to go for now and stable
> > > trees and we can come up with something less hackish later. I do not
> > > like the fact that oom_killer_disable doesn't act as a full "barrier"
> > > anymore.
> > > 
> > > What do you think?
> > 
> > I'm OK with calling try_to_freeze_tasks(true) again for Linux 4.6 and 4.7 kernels.
> 
> OK, I will resend the patch CC Rafael and stable.

Ohh, I've just realized that 449d777d7ad6 ("mm, oom_reaper: clear
TIF_MEMDIE for all tasks queued for oom_reaper") went in in this merge
window. So I've asked to push it to the next 4.7 rc.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
