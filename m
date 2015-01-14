Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 725436B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 11:01:09 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id z2so6396933wiv.5
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 08:01:08 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i4si48672268wjw.50.2015.01.14.08.01.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 08:01:07 -0800 (PST)
Date: Wed, 14 Jan 2015 11:01:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcontrol: default hierarchy interface for
 memory
Message-ID: <20150114160101.GA30018@phnom.home.cmpxchg.org>
References: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
 <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
 <xr93a91mz2s7.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93a91mz2s7.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jan 13, 2015 at 03:20:08PM -0800, Greg Thelen wrote:
> 
> On Thu, Jan 08 2015, Johannes Weiner wrote:
> 
> > Introduce the basic control files to account, partition, and limit
> > memory using cgroups in default hierarchy mode.
> >
> > This interface versioning allows us to address fundamental design
> > issues in the existing memory cgroup interface, further explained
> > below.  The old interface will be maintained indefinitely, but a
> > clearer model and improved workload performance should encourage
> > existing users to switch over to the new one eventually.
> >
> > The control files are thus:
> >
> >   - memory.current shows the current consumption of the cgroup and its
> >     descendants, in bytes.
> >
> >   - memory.low configures the lower end of the cgroup's expected
> >     memory consumption range.  The kernel considers memory below that
> >     boundary to be a reserve - the minimum that the workload needs in
> >     order to make forward progress - and generally avoids reclaiming
> >     it, unless there is an imminent risk of entering an OOM situation.
> 
> So this is try-hard, but no-promises interface.  No complaints.  But I
> assume that an eventual extension is a more rigid memory.min which
> specifies a minimum working set under which an container would prefer an
> oom kill to thrashing.

Yes, memory.min would nicely complement memory.max and I wouldn't be
opposed to adding it.  However, that does require at least some level
of cgroup-awareness in the global OOM killer in order to route kills
meaningfully according to cgroup configuration, which is mainly why I
deferred it in this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
