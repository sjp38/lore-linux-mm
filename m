Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id CC5946B0035
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 19:25:34 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id wp18so10269122obc.9
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 16:25:34 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id sm4si13294682obb.4.2014.03.31.16.25.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 16:25:34 -0700 (PDT)
Message-ID: <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 31 Mar 2014 16:25:32 -0700
In-Reply-To: <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	 <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
	 <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>
	 <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2014-03-31 at 16:13 -0700, Andrew Morton wrote:
> On Mon, 31 Mar 2014 15:59:33 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:
> 
> > > 
> > > - Shouldn't there be a way to alter this namespace's shm_ctlmax?
> > 
> > Unfortunately this would also add the complexity I previously mentioned.
> 
> But if the current namespace's shm_ctlmax is too small, you're screwed.
> Have to shut down the namespace all the way back to init_ns and start
> again.
> 
> > > - What happens if we just nuke the limit altogether and fall back to
> > >   the next check, which presumably is the rlimit bounds?
> > 
> > afaik we only have rlimit for msgqueues. But in any case, while I like
> > that simplicity, it's too late. Too many workloads (specially DBs) rely
> > heavily on shmmax. Removing it and relying on something else would thus
> > cause a lot of things to break.
> 
> It would permit larger shm segments - how could that break things?  It
> would make most or all of these issues go away?
> 

So sysadmins wouldn't be very happy, per man shmget(2):

EINVAL A new segment was to be created and size < SHMMIN or size >
SHMMAX, or no new segment was to be created, a segment with given key
existed, but size is greater than the size of that segment.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
