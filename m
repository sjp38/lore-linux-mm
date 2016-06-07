Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3466B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 18:15:46 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d191so130717087oig.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 15:15:46 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id 192si37052983pfw.92.2016.06.07.15.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 15:15:45 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id y124so22185028pfy.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 15:15:39 -0700 (PDT)
Date: Tue, 7 Jun 2016 15:15:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 06/10] mm, oom: kill all tasks sharing the mm
In-Reply-To: <20160606232007.GA624@redhat.com>
Message-ID: <alpine.DEB.2.10.1606071514550.18400@chino.kir.corp.google.com>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org> <1464945404-30157-7-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1606061526440.18843@chino.kir.corp.google.com> <20160606232007.GA624@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 7 Jun 2016, Oleg Nesterov wrote:

> On 06/06, David Rientjes wrote:
> >
> > > There is a potential race where we kill the oom disabled task which is
> > > highly unlikely but possible. It would happen if __set_oom_adj raced
> > > with select_bad_process and then it is OK to consider the old value or
> > > with fork when it should be acceptable as well.
> > > Let's add a little note to the log so that people would tell us that
> > > this really happens in the real life and it matters.
> > >
> >
> > We cannot kill oom disabled processes at all, little race or otherwise.
> 
> But this change doesn't really make it worse?
> 

Why is the patch asking users to report oom killing of a process that 
raced with setting /proc/pid/oom_score_adj to OOM_SCORE_ADJ_MIN?  What is 
possibly actionable about it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
