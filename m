Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 251DB6B00E1
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 11:07:10 -0500 (EST)
Date: Thu, 11 Mar 2010 17:06:16 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Patch] mm/ksm.c is doing an unneeded _notify in
 write_protect_page.
Message-ID: <20100311160616.GH5677@random.random>
References: <20100310191842.GL5677@sgi.com>
 <4B97FED5.2030007@redhat.com>
 <20100310221903.GC5967@random.random>
 <alpine.LSU.2.00.1003110617540.29040@sister.anvils>
 <4B98EE31.80502@redhat.com>
 <20100311155422.GB5685@sgi.com>
 <20100311180159.124ffecd@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100311180159.124ffecd@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Chris Wright <chrisw@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 11, 2010 at 06:01:59PM +0200, Izik Eidus wrote:
> On Thu, 11 Mar 2010 09:54:22 -0600
> Robin Holt <holt@sgi.com> wrote:
> 
> > 
> > ksm.c's write_protect_page implements a lockless means of verifying a
> > page does not have any users of the page which are not accounted for via
> > other kernel tracking means.  It does this by removing the writable pte
> > with TLB flushes, checking the page_count against the total known users,
> > and then using set_pte_at_notify to make it a read-only entry.
> > 
> > An unneeded mmu_notifier callout is made in the case where the known
> > users does not match the page_count.  In that event, we are inserting
> > the identical pte and there is no need for the set_pte_at_notify, but
> > rather the simpler set_pte_at suffices.
> > 
> > Signed-off-by: Robin Holt <holt@sgi.com>
> > To: Izik Eidus <ieidus@redhat.com>
> > Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > Cc: Chris Wright <chrisw@redhat.com>
> > Cc: linux-mm@kvack.org
> 
> Acked-by: Izik Eidus <ieidus@redhat.com>

Ack too. I misunderstood what you were talking about before, patch
makes it clear now ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
