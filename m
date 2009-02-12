Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B16136B0082
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 17:57:43 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1CMua2p003779
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 15:56:36 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1CMvfRG131632
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 15:57:41 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1CMveS5015501
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 15:57:41 -0700
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1234467035.3243.538.camel@calx>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	 <1234285547.30155.6.camel@nimitz>
	 <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz>  <1234467035.3243.538.camel@calx>
Content-Type: text/plain
Date: Thu, 12 Feb 2009 14:57:37 -0800
Message-Id: <1234479457.30155.214.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Cedric Le Goater <clg@fr.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-12 at 13:30 -0600, Matt Mackall wrote:
> On Thu, 2009-02-12 at 10:11 -0800, Dave Hansen wrote:
...
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

This is probably a better question for people like Pavel, Alexey and
Cedric to answer.  

> Some of these things we probably don't have to care too much about. For
> instance, contents of files - these can legitimately change for a
> running process. Open TCP/IP sockets can legitimately get reset as well.
> But others are a bigger deal.

Legitimately, yes.  But, practically, these are things that we need to
handle because we want to make any checkpoint/restart as transparent as
possible.  Resetting people's network connections is not exactly illegal
but not very nice or transparent either.

> Also, what happens if I checkpoint a process in 2.6.30 and restore it in
> 2.6.31 which has an expanded idea of what should be restored? Do your
> file formats handle this sort of forward compatibility or am I
> restricted to one kernel?

In general, you're restricted to one kernel.  But, people have mentioned
that, if the formats change, we should be able to write in-userspace
converters for the checkpoint files.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
