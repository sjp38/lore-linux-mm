Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 387546B00E8
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 18:10:06 -0500 (EST)
Received: by dadv6 with SMTP id v6so2466338dad.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 15:10:05 -0800 (PST)
Date: Fri, 2 Mar 2012 15:09:29 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: exit_mmap() BUG_ON triggering since 3.1
In-Reply-To: <20120302145811.93bb49e9.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1203021503420.3541@eggly.anvils>
References: <20120215183317.GA26977@redhat.com> <alpine.LSU.2.00.1202151801020.19691@eggly.anvils> <20120216070753.GA23585@redhat.com> <alpine.LSU.2.00.1202160130500.16147@eggly.anvils> <20120216214245.GD23585@redhat.com> <alpine.LSU.2.00.1203021444040.3448@eggly.anvils>
 <20120302145811.93bb49e9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Jones <davej@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fedoraproject.org

On Fri, 2 Mar 2012, Andrew Morton wrote:
> On Fri, 2 Mar 2012 14:53:32 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > Subject: Re: exit_mmap() BUG_ON triggering since 3.1
> > ...
> > Subject: [PATCH] mm: thp: fix BUG on mm->nr_ptes
> 
> So it's needed in 3.1.x and 3.2.x?

Indeed it would be needed in -stable, thanks, I forgot to add that.

And although Fedora only got reports from 3.1 onwards, I believe it
would equally be needed in 3.0.x.  3.1.x is closed down now, but
3.0.x and 3.2.x are still open.

I've not yet tried applying it to the latest of either of those: maybe
it applies cleanly and correctly, but I could imagine movements too.
But the first step, yes, is to Cc: stable@vger.kernel.org

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
