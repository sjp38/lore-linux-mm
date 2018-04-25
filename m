Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1850B6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 06:53:01 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e192-v6so5366185lfg.11
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 03:53:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b63-v6sor2790807lfb.40.2018.04.25.03.52.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 03:52:58 -0700 (PDT)
Date: Wed, 25 Apr 2018 13:52:55 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2] mm: introduce memory.min
Message-ID: <20180425105255.ixfuoanb6t4kr6l5@esperanza>
References: <20180423123610.27988-1-guro@fb.com>
 <20180424123002.utwbm54mu46q6aqs@esperanza>
 <20180424135409.GA28080@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424135409.GA28080@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>

On Tue, Apr 24, 2018 at 02:54:15PM +0100, Roman Gushchin wrote:
> > On Mon, Apr 23, 2018 at 01:36:10PM +0100, Roman Gushchin wrote:
> > > +  memory.min
> > > +	A read-write single value file which exists on non-root
> > > +	cgroups.  The default is "0".
> > > +
> > > +	Hard memory protection.  If the memory usage of a cgroup
> > > +	is within its effective min boundary, the cgroup's memory
> > > +	won't be reclaimed under any conditions. If there is no
> > > +	unprotected reclaimable memory available, OOM killer
> > > +	is invoked.
> > 
> > What will happen if all tasks attached to a cgroup are killed by OOM,
> > but its memory usage is still within memory.min? Will memory.min be
> > ignored then?
> 
> Not really.
> 
> I don't think it's a big problem as long as a user isn't doing
> something weird (e.g. moving processes with significant
> amount of charged memory to other cgroups).

The user doesn't have to do anything weird for this to happen - just
read a file. This will allocate and charge page cache pages that are
not mapped to any process and hence cannot be freed by OOM killer.

> 
> But what we can do here, is to ignore memory.min of empty cgroups
> (patch below), it will resolve some edge cases like this.

Makes sense to me.

Thanks,
Vladimir
