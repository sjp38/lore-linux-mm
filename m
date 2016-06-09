Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 699C66B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 02:46:38 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k192so12965511lfb.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 23:46:38 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id a6si3426976wjh.214.2016.06.08.23.46.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 23:46:37 -0700 (PDT)
Received: by mail-wm0-f48.google.com with SMTP id m124so45658250wme.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 23:46:36 -0700 (PDT)
Date: Thu, 9 Jun 2016 08:46:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 06/10] mm, oom: kill all tasks sharing the mm
Message-ID: <20160609064634.GC24777@dhcp22.suse.cz>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
 <1464945404-30157-7-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1606061526440.18843@chino.kir.corp.google.com>
 <20160606232007.GA624@redhat.com>
 <alpine.DEB.2.10.1606071514550.18400@chino.kir.corp.google.com>
 <20160608062219.GA22570@dhcp22.suse.cz>
 <alpine.DEB.2.10.1606081549490.12203@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1606081549490.12203@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 08-06-16 15:51:20, David Rientjes wrote:
> On Wed, 8 Jun 2016, Michal Hocko wrote:
> 
> > > Why is the patch asking users to report oom killing of a process that 
> > > raced with setting /proc/pid/oom_score_adj to OOM_SCORE_ADJ_MIN?  What is 
> > > possibly actionable about it?
> > 
> > Well, the primary point is to know whether such races happen in the real
> > loads and whether they actually matter. If yes we can harden the locking
> > or come up with a less racy solutions.
> 
> A thread being set to oom disabled while racing with the oom killer 
> obviously isn't a concern: it could very well be set to oom disabled after 
> the SIGKILL is sent and before the signal is handled, and that's not even 
> fixable without unneeded complexity because we don't know the source of 
> the SIGKILL.  Please remove the printk entirely.

OK, if you find it more confusing than useful I will not insist.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
