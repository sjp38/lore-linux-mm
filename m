Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 319AE6B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 22:16:18 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mz12so3591503bkb.30
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 19:16:17 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id l5si13113043bkr.287.2013.11.27.19.16.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 19:16:17 -0800 (PST)
Date: Wed, 27 Nov 2013 22:16:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131128031610.GL3556@cmpxchg.org>
References: <20131118154115.GA3556@cmpxchg.org>
 <20131118165110.GE32623@dhcp22.suse.cz>
 <20131122165100.GN3556@cmpxchg.org>
 <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
 <20131127163435.GA3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271343250.9222@chino.kir.corp.google.com>
 <20131127231931.GG3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271613340.10617@chino.kir.corp.google.com>
 <20131128022804.GJ3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271839290.5120@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311271839290.5120@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, Nov 27, 2013 at 06:52:10PM -0800, David Rientjes wrote:
> On Wed, 27 Nov 2013, Johannes Weiner wrote:
> 
> > The long-standing, user-visible definition of the current line agrees
> > with me.  You can't just redefine this, period.
> > 
> > I tried to explain to you how insane the motivation for this patch is,
> > but it does not look like you are reading what I write.  But you don't
> > get to change user-visible behavior just like that anyway, much less
> > so without a sane reason, so this was a complete waste of time :-(
> > 
> 
> If you would like to leave this to Andrew's decision, that's fine.  
> Michal has already agreed with my patch and has acked it in -mm.
> 
> If userspace is going to handle oom conditions, which is possible today 
> and will be extended in the future, then it should only wakeup as a last 
> resort when there is no possibility of future memory freeing.

I'll ack a patch that accomplishes that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
