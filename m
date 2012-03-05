Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 549046B007E
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 14:59:58 -0500 (EST)
Date: Mon, 5 Mar 2012 14:59:53 -0500
From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: exit_mmap() BUG_ON triggering since 3.1
Message-ID: <20120305195952.GC17489@zod.bos.redhat.com>
References: <20120215183317.GA26977@redhat.com>
 <alpine.LSU.2.00.1202151801020.19691@eggly.anvils>
 <20120216070753.GA23585@redhat.com>
 <alpine.LSU.2.00.1202160130500.16147@eggly.anvils>
 <20120216214245.GD23585@redhat.com>
 <alpine.LSU.2.00.1203021444040.3448@eggly.anvils>
 <20120302145811.93bb49e9.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1203021503420.3541@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1203021503420.3541@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Jones <davej@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fedoraproject.org

On Fri, Mar 02, 2012 at 03:09:29PM -0800, Hugh Dickins wrote:
> On Fri, 2 Mar 2012, Andrew Morton wrote:
> > On Fri, 2 Mar 2012 14:53:32 -0800 (PST)
> > Hugh Dickins <hughd@google.com> wrote:
> > 
> > > Subject: Re: exit_mmap() BUG_ON triggering since 3.1
> > > ...
> > > Subject: [PATCH] mm: thp: fix BUG on mm->nr_ptes
> > 
> > So it's needed in 3.1.x and 3.2.x?
> 
> Indeed it would be needed in -stable, thanks, I forgot to add that.
> 
> And although Fedora only got reports from 3.1 onwards, I believe it
> would equally be needed in 3.0.x.  3.1.x is closed down now, but
> 3.0.x and 3.2.x are still open.
> 
> I've not yet tried applying it to the latest of either of those: maybe
> it applies cleanly and correctly, but I could imagine movements too.
> But the first step, yes, is to Cc: stable@vger.kernel.org

I don't see this in linux-next, 3.3-rcX, the stable-queue, or really
anywhere at all at the moment.  Did the patch get swallowed up by some
kind of evil code Eagle of Doom before making it into the safety of a
tree somewhere?

josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
