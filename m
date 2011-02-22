Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 59ECD8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 11:43:37 -0500 (EST)
Date: Tue, 22 Feb 2011 17:43:31 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110222164331.GA31195@random.random>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org>
 <1298315270-10434-9-git-send-email-andi@firstfloor.org>
 <1298392586.9829.22566.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298392586.9829.22566.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>

On Tue, Feb 22, 2011 at 08:36:26AM -0800, Dave Hansen wrote:
> On Mon, 2011-02-21 at 11:07 -0800, Andi Kleen wrote:
> > From: Andi Kleen <ak@linux.intel.com>
> > 
> > I found it difficult to make sense of transparent huge pages without
> > having any counters for its actions. Add some counters to vmstat
> > for allocation of transparent hugepages and fallback to smaller
> > pages.
> > 
> > Optional patch, but useful for development and understanding the system.
> 
> Very nice.  I did the same thing, splits-only.  I also found this stuff
> a must-have for trying to do any work with transparent hugepages.  It's
> just impossible otherwise.

This patch is good too. 1 and 8 I think can go in, patch 1 is high
priority.

Patches 2-5 I've an hard time to see how they're not hurting
performance instead of improving it, especially patch 3 looks dead
wrong and has no chance by the very design of KSM and by the random
(vma-ignoring) NUMA affinity of PageKSM, patch 3 is most certainly a
regression.

Patch 6-7 I didn't evaluate those yet, they look good, even if low
priority.

Acked-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
