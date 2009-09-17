Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99A4D6B005A
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 16:39:23 -0400 (EDT)
Date: Thu, 17 Sep 2009 13:38:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: cgrooups && 2.6.32 -mm merge plans
Message-Id: <20090917133846.a00daece.akpm@linux-foundation.org>
In-Reply-To: <20090917201516.GA29346@redhat.com>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
	<20090917201516.GA29346@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, menage@google.com, bblum@google.com, ebiederm@xmission.com, lizf@cn.fujitsu.com, matthltc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 22:15:16 +0200
Oleg Nesterov <oleg@redhat.com> wrote:

> On 09/15, Andrew Morton wrote:
> >
> > #cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup.patch: Oleg conniptions
> > cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup.patch
> > cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup-fix.patch
> > cgroups-add-ability-to-move-all-threads-in-a-process-to-a-new-cgroup-atomically.patch
> >
> >   Merge after checking with Oleg.
> 
> Well. I think these patches are buggy :/
> 

Well that's never prevented us from merging stuff before.

Thanks, I'll disable the patches for now.  Do we have a grip on what's
wrong and what needs to be done to fix things?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
