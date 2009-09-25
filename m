Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A738D6B004D
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 09:59:01 -0400 (EDT)
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
	<20090924154139.2a7dd5ec.akpm@linux-foundation.org>
From: Dan Smith <danms@us.ibm.com>
Date: Fri, 25 Sep 2009 06:59:06 -0700
In-Reply-To: <20090924154139.2a7dd5ec.akpm@linux-foundation.org> (Andrew Morton's message of "Thu\, 24 Sep 2009 15\:41\:39 -0700")
Message-ID: <87ljk39lcl.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oren Laadan <orenl@librato.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, torvalds@linux-foundation.org, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

>> Q: What additional work needs to be done to it?  A: Fill in the
>> gory details following the examples so far. Current WIP includes
>> inet sockets, event-poll, and early work on inotify, mount
>> namespace and mount-points, pseudo file systems

AM> Will this new code muck up the kernel, or will it be clean?

I have (and have previously posted) prototype code to do c/r of open
sockets, ignoring some things like updating timers and such.  It looks
rather similar to the existing UNIX bits, and is even easier in some
ways.

One particular use case is only migrating listening sockets and
allowing the connected ones to be reset upon restart.  That enables a
bunch of things like apache, postfix, vncserver, and even sshd.  I
will pull the listen-only bits out of my current patch, scrape off a
little bitrot, and post them in a few days.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
