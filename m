Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 792536B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 16:17:10 -0500 (EST)
Message-ID: <50B52DC4.5000109@redhat.com>
Date: Tue, 27 Nov 2012 16:16:52 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org> <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com>
In-Reply-To: <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Thorsten Leemhuis <fedora@leemhuis.info>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 11/27/2012 03:58 PM, Linus Torvalds wrote:
> Note that in the meantime, I've also applied (through Andrew) the
> patch that reverts commit c654345924f7 (see commit 82b212f40059
> 'Revert "mm: remove __GFP_NO_KSWAPD"').
>
> I wonder if that revert may be bogus, and a result of this same issue.
> Maybe that revert should be reverted, and replaced with your patch?
>
> Mel? Zdenek? What's the status here?

Mel posted several patches to fix the kswapd issue.  This one is
slightly more risky than the outright revert, but probably preferred
from a performance point of view:

https://lkml.org/lkml/2012/11/12/151

It works by skipping the kswapd wakeup for THP allocations, only
if compaction is deferred or contended.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
