Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 828D36B0088
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 15:09:59 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6OJ9B4V006232
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 13:09:11 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6OJ9wdC189982
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 13:09:59 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6OJ9wER017927
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 13:09:58 -0600
Date: Fri, 24 Jul 2009 14:09:53 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v17][PATCH 00/60] Kernel based checkpoint/restart
Message-ID: <20090724190953.GA22641@us.ibm.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@librato.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@librato.com):
> Application checkpoint/restart (c/r) is the ability to save the state
> of a running application so that it can later resume its execution
> from the time at which it was checkpointed, on the same or a different
> machine.
> 
> This version introduces 'clone_with_pids()' syscall to preset pid(s)
> for a child process. It is used by restart(2) to recreate process
> hierarchy with the same pids as at checkpoint time.
> 
> It also adds a freezer state CHECKPOINTING to safeguard processes
> during a checkpoint. Other important changes include support for
> threads and zombies, credentials, signal handling, and improved
> restart logic. See below for a more detailed changelog.
> 
> Compiled and tested against v2.6.31-rc3.

With the s390 patch I recently sent on top of this set, all of my
c/r tests pass, and ltp behaves the same as on plain v2.6.31-rc3
(up to and including hanging on mallocstress).

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
