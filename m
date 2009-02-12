Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7891D6B003D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 14:31:06 -0500 (EST)
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1234462282.30155.171.camel@nimitz>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	 <1234285547.30155.6.camel@nimitz>
	 <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz>
Content-Type: text/plain
Date: Thu, 12 Feb 2009 13:30:35 -0600
Message-Id: <1234467035.3243.538.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-12 at 10:11 -0800, Dave Hansen wrote:

> > - In bullet-point form, what features are missing, and should be added?
> 
>  * support for more architectures than i386
>  * file descriptors:
>   * sockets (network, AF_UNIX, etc...)
>   * devices files
>   * shmfs, hugetlbfs
>   * epoll
>   * unlinked files

>  * Filesystem state
>   * contents of files
>   * mount tree for individual processes
>  * flock
>  * threads and sessions
>  * CPU and NUMA affinity
>  * sys_remap_file_pages()

I think the real questions is: where are the dragons hiding? Some of
these are known to be hard. And some of them are critical checkpointing
typical applications. If you have plans or theories for implementing all
of the above, then great. But this list doesn't really give any sense of
whether we should be scared of what lurks behind those doors.

Some of these things we probably don't have to care too much about. For
instance, contents of files - these can legitimately change for a
running process. Open TCP/IP sockets can legitimately get reset as well.
But others are a bigger deal.

Also, what happens if I checkpoint a process in 2.6.30 and restore it in
2.6.31 which has an expanded idea of what should be restored? Do your
file formats handle this sort of forward compatibility or am I
restricted to one kernel?

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
