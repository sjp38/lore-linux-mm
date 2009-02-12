Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB0F6B003D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 14:42:58 -0500 (EST)
Date: Thu, 12 Feb 2009 11:42:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Message-Id: <20090212114207.e1c2de82.akpm@linux-foundation.org>
In-Reply-To: <1234467035.3243.538.camel@calx>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>
	<1234467035.3243.538.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: dave@linux.vnet.ibm.com, mingo@elte.hu, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Thu, 12 Feb 2009 13:30:35 -0600
Matt Mackall <mpm@selenic.com> wrote:

> On Thu, 2009-02-12 at 10:11 -0800, Dave Hansen wrote:
> 
> > > - In bullet-point form, what features are missing, and should be added?
> > 
> >  * support for more architectures than i386
> >  * file descriptors:
> >   * sockets (network, AF_UNIX, etc...)
> >   * devices files
> >   * shmfs, hugetlbfs
> >   * epoll
> >   * unlinked files
> 
> >  * Filesystem state
> >   * contents of files
> >   * mount tree for individual processes
> >  * flock
> >  * threads and sessions
> >  * CPU and NUMA affinity
> >  * sys_remap_file_pages()
> 
> I think the real questions is: where are the dragons hiding? Some of
> these are known to be hard. And some of them are critical checkpointing
> typical applications. If you have plans or theories for implementing all
> of the above, then great. But this list doesn't really give any sense of
> whether we should be scared of what lurks behind those doors.

How close has OpenVZ come to implementing all of this?  I think the
implementatation is fairly complete?

If so, perhaps that can be used as a guide.  Will the planned feature
have a similar design?  If not, how will it differ?  To what extent can
we use that implementation as a tool for understanding what this new
implementation will look like?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
