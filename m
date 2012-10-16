Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 65F3F6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:53:15 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so3732742dad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 06:53:14 -0700 (PDT)
Date: Tue, 16 Oct 2012 22:53:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm: teach mm by current context info to not do
 I/O during memory allocation
Message-ID: <20121016135308.GA6958@barrios>
References: <1350278059-14904-1-git-send-email-ming.lei@canonical.com>
 <1350278059-14904-2-git-send-email-ming.lei@canonical.com>
 <20121015154724.GA2840@barrios>
 <CACVXFVM09H=8ZuFSzkcN1NmOCR1pcPUsuUyT9tpR0doVam2BiQ@mail.gmail.com>
 <20121016054946.GA3934@barrios>
 <CACVXFVOdohPprD7N69=Tz2keTbLG7b-s5324OUX-oY84Jszumg@mail.gmail.com>
 <20121016130927.GA5603@barrios>
 <CACVXFVMr=JMNHFe1GO=di99eB-6-=_pBkP3QH4x_qtKhdRZMFw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVXFVMr=JMNHFe1GO=di99eB-6-=_pBkP3QH4x_qtKhdRZMFw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Jiri Kosina <jiri.kosina@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

On Tue, Oct 16, 2012 at 09:47:03PM +0800, Ming Lei wrote:
> On Tue, Oct 16, 2012 at 9:09 PM, Minchan Kim <minchan@kernel.org> wrote:
> >
> > Good point. You can check it in __zone_reclaim and change gfp_mask of scan_control
> > because it's never hot path.
> >
> >>
> >> So could you make sure it is safe to move the branch into
> >> __alloc_pages_slowpath()?  If so, I will add the check into
> >> gfp_to_alloc_flags().
> >
> > How about this?
> 
> It is quite smart change, :-)
> 
> Considered that other part(sched.h) of the patch need update, I
> will merge your change into -v1 for further review with your
> Signed-off-by if you have no objection.

No problem. :)

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
