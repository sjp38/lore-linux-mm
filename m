Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5EF076B00CD
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 15:31:53 -0500 (EST)
Date: Wed, 23 Nov 2011 12:31:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/8] readahead: replace ra->mmap_miss with ra->ra_flags
Message-Id: <20111123123150.8a1ac462.akpm@linux-foundation.org>
In-Reply-To: <20111123124745.GB7174@localhost>
References: <20111121091819.394895091@intel.com>
	<20111121093846.378529145@intel.com>
	<20111121150116.094cf194.akpm@linux-foundation.org>
	<20111123124745.GB7174@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Steven Whitehouse <swhiteho@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, 23 Nov 2011 20:47:45 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> > should be ulong, which is compatible with the bitops.h code.
> > Or perhaps we should use a bitfield and let the compiler do the work.
> 
> What if we do
> 
>         u16     mmap_miss;
>         u16     ra_flags;
> 
> That would get rid of this patch. I'd still like to pack the various
> flags as well as pattern into one single ra_flags, which makes it
> convenient to pass things around (as one single parameter).

I'm not sure that this will improve things much...

Again, how does the code look if you use a bitfield and let the
compiler do the worK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
