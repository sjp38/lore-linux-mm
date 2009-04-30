Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 813C06B0047
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 00:54:57 -0400 (EDT)
Date: Wed, 29 Apr 2009 21:55:26 -0700
From: Elladan <elladan@eskimo.com>
Subject: Re: Swappiness vs. mmap() and interactive response
Message-ID: <20090430045525.GC6110@eskimo.com>
References: <20090428090916.GC17038@localhost> <20090428120818.GH22104@mit.edu> <20090429130430.4B11.A69D9226@jp.fujitsu.com> <20090428233455.614dcf3a.akpm@linux-foundation.org> <20090430041439.GA6110@eskimo.com> <20090429214332.a2b5b469.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090429214332.a2b5b469.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Elladan <elladan@eskimo.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 09:43:32PM -0700, Andrew Morton wrote:
> On Wed, 29 Apr 2009 21:14:39 -0700 Elladan <elladan@eskimo.com> wrote:
> 
> > > Elladan, have you checked to see whether the Mapped: number in
> > > /proc/meminfo is decreasing?
> > 
> > Yes, Mapped decreases while a large file copy is ongoing.  It increases again
> > if I use the GUI.
> 
> OK.  If that's still happening to an appreciable extent after you've
> increased /proc/sys/vm/swappiness then I'd wager that we have a
> bug/regression in that area.
> 
> Local variable `scan' in shrink_zone() is vulnerable to multiplicative
> overflows on large zones, but I doubt if you have enough memory to
> trigger that bug.

No, I only have 4GB.

This appears to happen with swappiness set to 0 or 60.

-Elladan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
