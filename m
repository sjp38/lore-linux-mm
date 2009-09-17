Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9479E6B0082
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 17:12:11 -0400 (EDT)
Date: Thu, 17 Sep 2009 23:08:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: cgrooups && 2.6.32 -mm merge plans
Message-ID: <20090917210806.GA31441@redhat.com>
References: <20090915161535.db0a6904.akpm@linux-foundation.org> <20090917201516.GA29346@redhat.com> <20090917133846.a00daece.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090917133846.a00daece.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, menage@google.com, bblum@google.com, ebiederm@xmission.com, lizf@cn.fujitsu.com, matthltc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 09/17, Andrew Morton wrote:
>
> On Thu, 17 Sep 2009 22:15:16 +0200
> Oleg Nesterov <oleg@redhat.com> wrote:
>
> > On 09/15, Andrew Morton wrote:
> > >
> > > #cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup.patch: Oleg conniptions
> > > cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup.patch
> > > cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup-fix.patch
> > > cgroups-add-ability-to-move-all-threads-in-a-process-to-a-new-cgroup-atomically.patch
> > >
> > >   Merge after checking with Oleg.
> >
> > Well. I think these patches are buggy :/
> >
>
> Well that's never prevented us from merging stuff before.
>
> Thanks, I'll disable the patches for now.  Do we have a grip on what's
> wrong and what needs to be done to fix things?

Afaics, ->threadgroup_fork_lock doesn't really work, we can race with exec.

list_for_each_entry_rcu() loops in these patches are not safe.

And in fact, personally I dislike even atomic_inc(&sighand->count). Just
consider sys_unshare(CLONE_SIGHAND). Yes, this code is a joke, but still.


Sadly, I don't have any ideas how to fix this... I'd wish I had a time
to at least try to find the solution ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
