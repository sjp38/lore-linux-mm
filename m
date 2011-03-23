Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BBA0F8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 11:05:11 -0400 (EDT)
Date: Wed, 23 Mar 2011 11:04:06 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v2 resend 0/12] enable writing to /proc/pid/mem
Message-ID: <20110323150406.GA16511@fibrous.localdomain>
References: <1300891441-16280-1-git-send-email-wilsons@start.ca> <20110323145748.GA22723@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110323145748.GA22723@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andi Kleen <ak@linux.intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 23, 2011 at 02:57:49PM +0000, Al Viro wrote:
> On Wed, Mar 23, 2011 at 10:43:49AM -0400, Stephen Wilson wrote:
> > Hello,
> > 
> > This is a resend[1] of a patch series that implements safe writes to
> > /proc/pid/mem.  Such functionality is useful as it gives debuggers a simple and
> > efficient mechanism to manipulate a process' address space.  Memory can be read
> > and written using single calls to pread(2) and pwrite(2) instead of iteratively
> > calling into ptrace(2).
> 
> It's in local queue already, along with other procfs fixes; I'm going to push
> it today, with several more procfs race fixes added.

Ah, OK.  I had no idea.  Thanks so much!


-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
