Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AA7F16B00A5
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 18:27:35 -0500 (EST)
Date: Thu, 11 Nov 2010 15:27:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
Message-Id: <20101111152732.6c6544b3.akpm@linux-foundation.org>
In-Reply-To: <1289517594.428.153.camel@oralap>
References: <1289421759.11149.59.camel@oralap>
	<20101111120643.22dcda5b.akpm@linux-foundation.org>
	<1289512924.428.112.camel@oralap>
	<20101111142511.c98c3808.akpm@linux-foundation.org>
	<1289515558.428.125.camel@oralap>
	<1289517594.428.153.camel@oralap>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Cc: linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Nov 2010 00:19:54 +0100
"Ricardo M. Correia" <ricardo.correia@oracle.com> wrote:

> On Thu, 2010-11-11 at 23:45 +0100, Ricardo M. Correia wrote:
> > On Thu, 2010-11-11 at 14:25 -0800, Andrew Morton wrote:
> > > And then we can set current->gfp_mask to GFP_ATOMIC when we take an
> > > interrupt, or take a spinlock.
> 
> Also, doesn't this mean that spin_lock() would now have to save
> current->gfp_flags in the stack?
> 
> So that we can restore the allocation mode when we do spin_unlock()?

If we wanted to go that far, yes.  Who's up for editing every spin_lock()
callsite in the kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
