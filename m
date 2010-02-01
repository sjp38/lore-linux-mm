Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9B12D6B004D
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 14:07:06 -0500 (EST)
Date: Mon, 1 Feb 2010 13:07:04 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP 2/3] Fix unmap_vma() bug related to mmu_notifiers
Message-ID: <20100201190704.GK6653@sgi.com>
References: <20100128195627.373584000@alcatraz.americas.sgi.com>
 <20100128195634.355405000@alcatraz.americas.sgi.com>
 <20100129125426.2cde0a5f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100129125426.2cde0a5f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 29, 2010 at 12:54:26PM -0800, Andrew Morton wrote:
> On Thu, 28 Jan 2010 13:56:29 -0600
> Robin Holt <holt@sgi.com> wrote:
> 
> > 
> > unmap_vmas() can fail to correctly flush the TLB if a
> > callout to mmu_notifier_invalidate_range_start() sleeps.
> > The mmu_gather list is initialized prior to the callout. If it is reused
> > while the thread is sleeping, the mm field may be invalid.
> > 
> > If the task migrates to a different cpu, the task may use the wrong
> > mmu_gather.
> 
> I don't think that description is complete.
> 
> There might be ways in which we can prevent this task from being
> migrated to another CPU, but that doesn't fix the problem because the
> mmu_gather is a per-CPU resource and might get trashed if another task
> is scheduled on THIS cpu, and uses its mmu_gather.

I couldn't reword it to make it any more clear.  The third paragraph of
Jack's original changelog says basically what you said.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
