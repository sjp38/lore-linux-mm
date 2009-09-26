Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2E76B0055
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 10:56:06 -0400 (EDT)
Date: Sat, 26 Sep 2009 16:56:06 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
Message-ID: <20090926145606.GA30071@elte.hu>
References: <1253749920-18673-1-git-send-email-orenl@librato.com> <20090924154139.2a7dd5ec.akpm@linux-foundation.org> <87ljk39lcl.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ljk39lcl.fsf@caffeine.danplanet.com>
Sender: owner-linux-mm@kvack.org
To: Dan Smith <danms@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oren Laadan <orenl@librato.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, xemul@openvz.org
List-ID: <linux-mm.kvack.org>


* Dan Smith <danms@us.ibm.com> wrote:

> >> Q: What additional work needs to be done to it?  A: Fill in the
> >> gory details following the examples so far. Current WIP includes
> >> inet sockets, event-poll, and early work on inotify, mount
> >> namespace and mount-points, pseudo file systems
> 
> AM> Will this new code muck up the kernel, or will it be clean?
> 
> I have (and have previously posted) prototype code to do c/r of open 
> sockets, ignoring some things like updating timers and such.  It looks 
> rather similar to the existing UNIX bits, and is even easier in some 
> ways.
> 
> One particular use case is only migrating listening sockets and 
> allowing the connected ones to be reset upon restart.  That enables a 
> bunch of things like apache, postfix, vncserver, and even sshd.  I 
> will pull the listen-only bits out of my current patch, scrape off a 
> little bitrot, and post them in a few days.

That looks useful. (Btw., the other four questions Andrew asked look 
relevant too.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
