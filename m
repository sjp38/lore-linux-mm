Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C04036B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 18:42:17 -0400 (EDT)
Date: Thu, 24 Sep 2009 15:41:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
Message-Id: <20090924154139.2a7dd5ec.akpm@linux-foundation.org>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@librato.com>
Cc: torvalds@linux-foundation.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, serue@us.ibm.com, mingo@elte.hu, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Sep 2009 19:50:40 -0400
Oren Laadan <orenl@librato.com> wrote:

> Q: How useful is this code as it stands in real-world usage?
> A: The application can be single- or multi-processes and threads. It
>    handles open files (regular files/directories on most file systems,
>    pipes, fifos, af_unix sockets, /dev/{null,zero,random,urandom} and
>    pseudo-terminals. It supports shared memory. sysv IPC (except undo
>    of sempahores). It's suitable for many types of batch jobs as well
>    as some interactive jobs. (Note: it is assumed that the fs view is
>    available at restart).

That's encouraging.

> Q: What can it checkpoint and restart ?
> A: A (single threaded) process can checkpoint itself, aka "self"
>    checkpoint, if it calls the new system calls. Otherise, for an
>    "external" checkpoint, the caller must first freeze the target
>    processes. One can either checkpoint an entire container (and
>    we make best effort to ensure that the result is self-contained),
>    or merely a subtree of a process hierarchy.

What is "best effort"?  Will the operation appear to have succeeded,
only it didn't?

IOW, how reliable and robust is code at detecting that it was unable to
successfully generate a restartable image?

> Q: What about namespaces ?
> A: Currrently, UTS and IPC namespaces are restored. They demonstrate
>    how namespaces are handled. More to come.

Will this new code muck up the kernel?

> Q: What additional work needs to be done to it?
> A: Fill in the gory details following the examples so far. Current WIP
>    includes inet sockets, event-poll, and early work on inotify, mount
>    namespace and mount-points, pseudo file systems

Will this new code muck up the kernel, or will it be clean?

> and x86_64 support.

eh?  You mean the code doesn't work on x86_64 at present?


What is the story on migration?  Moving the process(es) to a different
machine?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
