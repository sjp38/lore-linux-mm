Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 589086B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 02:22:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 4so556888wmz.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 23:22:23 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id s125si246287wme.29.2016.06.07.23.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 23:22:22 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id k204so1404840wmk.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 23:22:21 -0700 (PDT)
Date: Wed, 8 Jun 2016 08:22:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 06/10] mm, oom: kill all tasks sharing the mm
Message-ID: <20160608062219.GA22570@dhcp22.suse.cz>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
 <1464945404-30157-7-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1606061526440.18843@chino.kir.corp.google.com>
 <20160606232007.GA624@redhat.com>
 <alpine.DEB.2.10.1606071514550.18400@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1606071514550.18400@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 07-06-16 15:15:37, David Rientjes wrote:
> On Tue, 7 Jun 2016, Oleg Nesterov wrote:
> 
> > On 06/06, David Rientjes wrote:
> > >
> > > > There is a potential race where we kill the oom disabled task which is
> > > > highly unlikely but possible. It would happen if __set_oom_adj raced
> > > > with select_bad_process and then it is OK to consider the old value or
> > > > with fork when it should be acceptable as well.
> > > > Let's add a little note to the log so that people would tell us that
> > > > this really happens in the real life and it matters.
> > > >
> > >
> > > We cannot kill oom disabled processes at all, little race or otherwise.
> > 
> > But this change doesn't really make it worse?
> > 
> 
> Why is the patch asking users to report oom killing of a process that 
> raced with setting /proc/pid/oom_score_adj to OOM_SCORE_ADJ_MIN?  What is 
> possibly actionable about it?

Well, the primary point is to know whether such races happen in the real
loads and whether they actually matter. If yes we can harden the locking
or come up with a less racy solutions.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
