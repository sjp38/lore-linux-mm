Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 515066B00EC
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 20:22:08 -0500 (EST)
Received: by iajr24 with SMTP id r24so10228898iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 17:22:05 -0800 (PST)
Date: Tue, 6 Mar 2012 17:21:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] ksm: clean up page_trans_compound_anon_split
In-Reply-To: <20120307001148.GO13462@redhat.com>
Message-ID: <alpine.LSU.2.00.1203061717380.1431@eggly.anvils>
References: <1330594374-13497-1-git-send-email-lliubbo@gmail.com> <alpine.LSU.2.00.1203061515470.1292@eggly.anvils> <20120307001148.GO13462@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org

On Wed, 7 Mar 2012, Andrea Arcangeli wrote:
> On Tue, Mar 06, 2012 at 03:28:43PM -0800, Hugh Dickins wrote:
> > On Thu, 1 Mar 2012, Bob Liu wrote:
> > 
> > > Signed-off-by: Bob Liu <lliubbo@gmail.com>
> > 
> > I agree it looks very much nicer: a patch on these lines would be good.
> > 
> > But you've lost the comment about a return of 1 meaning "Retry later if
> > split_huge_page run from under us", which I think was a helpful comment.
> > 
> > And you've not commented on the functional change which you made:
> > if page_trans_compound_anon() returns NULL, then _split() now returns
> > 1 where before it returned 0.  I suspect that's a reasonable change
> > in a rare case, and better left simple as you have it, than slavishly
> > reproduce the earlier behaviour; but I'd like to have an Ack from the
> > author before we commit your modification.
> 
> Yes, it's not a "noop", I just read the patch through the -mm flow a
> few sec after reading the above.
> 
> > But you didn't Cc Andrea whose code this is, and who understands THP
> > and its races better than anybody: now Cc'ed.
> 
> Thanks for CCing me. Returning 1 when page_trans_compound_anon returns
> NULL, should still be safe, because 1 triggers the bail out path, so
> it won't harm. It should be fully equivalent too because it would bail
> out later in the PageAnon check if page_trans_compound_anon returned 0
> (the function was invoked only on compound pages in the first place).
> 
> So it looks fine.

Thanks, Andrea, that's good.  So Bob, please resubmit with comment on
return value 1 reinstated, and in the commit description explain how
the slight change in operation is benign.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
