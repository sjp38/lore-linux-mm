Subject: Re: [PATCH] 2.6.4-rc2-mm1: vm-split-active-lists
Message-ID: <OF9DC8F5B1.0044A21E-ON86256E55.004DF368@raytheon.com>
From: Mark_H_Johnson@Raytheon.com
Date: Fri, 12 Mar 2004 08:18:15 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mfedyk@matchmail.com, m.c.p@wolk-project.de, owner-linux-mm@kvack.org, plate@gmx.tm
List-ID: <linux-mm.kvack.org>




Nick Piggin <piggin@cyberone.com.au> wrote:
>Andrew Morton wrote:

>>That effect is to cause the whole world to be swapped out when people
>>return to their machines in the morning.  Once they're swapped back in
the
>>first thing they do it send bitchy emails to you know who.
>>
>>>From a performance perspective it's the right thing to do, but nobody
likes
>>it.
>>
>>
>
>Yeah. I wonder if there is a way to be smarter about dropping these
>used once pages without putting pressure on more permanent pages...
>I guess all heuristics will fall down somewhere or other.

Just a question, but I remember from VMS a long time ago that
as part of the working set limits, the "free list" was used to keep
pages that could be freely used but could be put back into the working
set quite easily (a "fast" page fault). Could you keep track of the
swapped pages in a similar manner so you don't have to go to disk to
get these pages [or is this already being done]? You would pull them
back from the free list and avoid the disk I/O in the morning.

By the way - with 2.4.24 I see a similar behavior anyway [slow to get
going in the morning]. I believe it is due to our nightly backup walking
through the disks. If you could FIX the retention of sequentially read
disk blocks from the various caches - that would help a lot more in
my mind.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
