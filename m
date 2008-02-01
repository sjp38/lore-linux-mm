Date: Thu, 31 Jan 2008 20:24:44 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/3] mmu_notifier: Core code
Message-ID: <20080201022444.GA26420@sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.553249048@sgi.com> <20080201015611.GA15893@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080201015611.GA15893@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 07:56:12PM -0600, Jack Steiner wrote:
> > @@ -2033,6 +2034,7 @@ void exit_mmap(struct mm_struct *mm)
> >  	unsigned long end;
> >  
> >  	/* mm's last user has gone, and its about to be pulled down */
> > +	mmu_notifier(invalidate_all, mm, 0);
> >  	arch_exit_mmap(mm);
> >  
> 
> The name of the "invalidate_all" callout is not very descriptive.
> Why not use "exit_mmap". That matches the function name, the arch callout
> and better describes what is happening.

This got removed in a later patch.  We now only do the release.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
