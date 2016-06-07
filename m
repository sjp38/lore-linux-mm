Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36A7E6B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 02:37:43 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k192so14250206lfb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 23:37:43 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id a138si23279012wmd.114.2016.06.06.23.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 23:37:41 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id v199so3872038wmv.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 23:37:41 -0700 (PDT)
Date: Tue, 7 Jun 2016 08:37:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 06/10] mm, oom: kill all tasks sharing the mm
Message-ID: <20160607063738.GB12305@dhcp22.suse.cz>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
 <1464945404-30157-7-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1606061526440.18843@chino.kir.corp.google.com>
 <20160606232007.GA624@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606232007.GA624@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 07-06-16 01:20:08, Oleg Nesterov wrote:
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

Exactly, the race was always there. We could mitigate it to some degree
by (ab)using oom_lock in __set_oom_adj. But I guess this is just an
overkill.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
