Subject: Re: [PATCH] recognize MAP_LOCKED in mmap() call
Message-ID: <OFC0C42F8D.E1325D58-ON86256C38.00695CD8@hou.us.ray.com>
From: Mark_H_Johnson@raytheon.com
Date: Wed, 18 Sep 2002 14:18:05 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>(SuS really only anticipates that mmap needs to look at prior mlocks
>in force against the address range.  It also says
>
>     Process memory locking does apply to shared memory regions,
>
>and we don't do that either.  I think we should; can't see why SuS
>requires this.)

Let me make sure I read what you said correctly. Does this mean that Linux
2.4 (or 2.5) kernels do not lock shared memory regions if a process uses
mlockall?

If not, that is *really bad* for our real time applications. We don't want
to take a page fault while running some 80hz task, just because some
non-real time application tried to use what little physical memory we allow
for the kernel and all other applications.

I asked a related question about a week ago on linux-mm and didn't get a
response. Basically, I was concerned that top did not show RSS == Size when
mlockall(MCL_CURRENT|MCL_FUTURE) was called. Could this explain the
difference or is there something else that I'm missing here?

Thanks.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
