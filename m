Received: from mountain.net ([198.77.57.48]) by riker.mountain.net
          (Post.Office MTA v3.5.3 release 223 ID# 0-0U10L2S100V35)
          with ESMTP id net for <linux-mm@kvack.org>;
          Sun, 11 Feb 2001 01:30:30 -0500
Message-ID: <3A8631AB.BCC39E26@mountain.net>
Date: Sun, 11 Feb 2001 01:31:07 -0500
From: Tom Leete <tleete@mountain.net>
MIME-Version: 1.0
Subject: [QUERY] Value of seperate mm_struct.h?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello all,

I produced a patch, k7-smp-include.patch, which splits task_struct out of
sched.h into its own header. In doing that I inadvertently did the same for
mm_struct (thought I was going to need it). I plan to revert that, but I'll
leave it in if the consensus here wants it.

The patch was posted to linux-kernel at 14:49:30 UTC, Feb 10, under the
Subject: '[PATCH} Athlon-SMP compiles & runs. inline fns honored'

Cheers,
Tom

-- 
The Daemons lurk and are dumb. -- Emerson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
