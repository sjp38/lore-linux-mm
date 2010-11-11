Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 12F006B00A7
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 18:29:20 -0500 (EST)
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
From: "Ricardo M. Correia" <ricardo.correia@oracle.com>
In-Reply-To: <20101111152732.6c6544b3.akpm@linux-foundation.org>
References: <1289421759.11149.59.camel@oralap>
	 <20101111120643.22dcda5b.akpm@linux-foundation.org>
	 <1289512924.428.112.camel@oralap>
	 <20101111142511.c98c3808.akpm@linux-foundation.org>
	 <1289515558.428.125.camel@oralap> <1289517594.428.153.camel@oralap>
	 <20101111152732.6c6544b3.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 12 Nov 2010 00:29:10 +0100
Message-ID: <1289518150.428.165.camel@oralap>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-11-11 at 15:27 -0800, Andrew Morton wrote:
> On Fri, 12 Nov 2010 00:19:54 +0100
> "Ricardo M. Correia" <ricardo.correia@oracle.com> wrote:
> 
> > On Thu, 2010-11-11 at 23:45 +0100, Ricardo M. Correia wrote:
> > > On Thu, 2010-11-11 at 14:25 -0800, Andrew Morton wrote:
> > > > And then we can set current->gfp_mask to GFP_ATOMIC when we take an
> > > > interrupt, or take a spinlock.
> > 
> > Also, doesn't this mean that spin_lock() would now have to save
> > current->gfp_flags in the stack?
> > 
> > So that we can restore the allocation mode when we do spin_unlock()?
> 
> If we wanted to go that far, yes.  Who's up for editing every spin_lock()
> callsite in the kernel?

Hmm... Coccinelle? ;) [1]

[1] http://coccinelle.lip6.fr/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
