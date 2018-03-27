Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 176CD6B0026
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 09:52:21 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id o4so10102681ywc.16
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 06:52:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n130-v6sor168635yba.72.2018.03.27.06.52.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 06:52:20 -0700 (PDT)
Date: Tue, 27 Mar 2018 06:52:17 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] mm, memcontrol: Implement memory.swap.events
Message-ID: <20180327135217.GI1840639@devbig577.frc2.facebook.com>
References: <20180324165127.701194-1-tj@kernel.org>
 <20180326143931.41a15320fd4d4af26c86d42e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180326143931.41a15320fd4d4af26c86d42e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, guro@fb.com, riel@surriel.com, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 26, 2018 at 02:39:31PM -0700, Andrew Morton wrote:
> On Sat, 24 Mar 2018 09:51:25 -0700 Tejun Heo <tj@kernel.org> wrote:
> 
> > This patchset implements memory.swap.events which contains max and
> > fail events so that userland can monitor and respond to swap running
> > out.  It contains the following two patches.
> > 
> >  0001-mm-memcontrol-Move-swap-charge-handling-into-get_swa.patch
> >  0002-mm-memcontrol-Implement-memory.swap.events.patch
> > 
> > This patchset is on top of the "cgroup/for-4.17: Make cgroup_rstat
> > available to controllers" patchset[1] and "mm, memcontrol: Make
> > cgroup_rstat available to controllers" patchset[2] and also available
> > in the following git branch.
> > 
> >  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-memcg-swap.events
> 
> This doesn't appear to be in linux-next yet.  It should be by now if it's
> targeted at 4.17?

You're right.  It's too late for 4.17.  Let's aim for 4.18.

Thanks.

-- 
tejun
