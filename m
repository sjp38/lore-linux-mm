Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id E16576B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 13:11:01 -0400 (EDT)
Received: by mail-bk0-f45.google.com with SMTP id na10so326167bkb.32
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 10:11:01 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id t2si3499048bkh.185.2014.04.04.10.11.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 04 Apr 2014 10:11:00 -0700 (PDT)
Date: Fri, 4 Apr 2014 13:10:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 0/3] Per-cgroup swap file support
Message-ID: <20140404171056.GX14688@cmpxchg.org>
References: <1396470849-26154-1-git-send-email-yuzhao@google.com>
 <20140402205433.GW14688@cmpxchg.org>
 <20140402212949.GA29322@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140402212949.GA29322@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, jamieliu@google.com, suleiman@google.com

Hi Yu,

On Wed, Apr 02, 2014 at 02:29:49PM -0700, Yu Zhao wrote:
> On Wed, Apr 02, 2014 at 04:54:33PM -0400, Johannes Weiner wrote:
> > On Wed, Apr 02, 2014 at 01:34:06PM -0700, Yu Zhao wrote:
> > > This series of patches adds support to configure a cgroup to swap to a
> > > particular file by using control file memory.swapfile.
> > > 
> > > Originally, cgroups share system-wide swap space and limiting cgroup swapping
> > > is not possible. This patchset solves the problem by adding mechanism that
> > > isolates cgroup swap spaces (i.e. per-cgroup swap file) so users can safely
> > > enable swap for particular cgroups without worrying about one cgroup uses up
> > > all swap space.
> > 
> > Isn't that what the swap controller is for?
> 
> Well, I should've used word "isolating" instead of "limiting" (and yes, the
> example I gave is confusing too). MEMCG_SWAP limits swaping while per-cgroup
> swap file not only limits but also isolates the swap space. In another word,
> per-cgroup swap file acts like the cgroup owns its private swap file which
> can be specified to a particular path when users want the cgroup to swap to
> a disk volumes rather than the one used by default (system-wide) swap files.

This is still too vague.  You want us to merge 300 lines of code and
userspace ABI that we have to maintain indefinitely.  Please elaborate
on the problem you are trying to solve and what type of workloads are
affected, and then why per-cgroup swap files are the best solution to
this problem.

Also, there seems to be quite some overlap in functionality with the
swap controller, so should we go down the per-cgroup swap file road,
we might want to consider dropping the swap controller in exchange.

Remember that Linux is a general-purpose operating system with many
different applications, so obviously we want to maximize general
usefulness out of any functionality we provide.  And for that it's
important for us to truly understand the problem space.  Please keep
this in mind when writing changelogs and introductory emails for new
features.

Thanks,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
