Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0366B007B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 17:24:25 -0400 (EDT)
Date: Thu, 2 Jun 2011 14:23:48 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] ksm: fix race between ksmd and exiting task
Message-ID: <20110602212348.GM23047@sequoia.sous-sol.org>
References: <20110601222032.GA2858@thinkpad>
 <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <20110602141927.GA2011@thinkpad>
 <20110602164841.GK23047@sequoia.sous-sol.org>
 <20110602173549.GL23047@sequoia.sous-sol.org>
 <20110602201236.GB4114@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602201236.GB4114@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Chris Wright <chrisw@sous-sol.org>, CAI Qian <caiqian@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

* Andrea Righi (andrea@betterlinux.com) wrote:
> On Thu, Jun 02, 2011 at 10:35:49AM -0700, Chris Wright wrote:
> > Andrea Righi reported a case where an exiting task can race against
> > ksmd.
> > 
> > ksm_scan.mm_slot == the only registered mm
> > CPU 1 (bug program)		CPU 2 (ksmd)
> >  				list_empty() is false
> > lock
> > ksm_scan.mm_slot
> > list_del
> > unlock
> >  				slot == &ksm_mm_head (but list is now empty_)
> > 
> > Close this race by revalidating that the new slot is not simply the list
> > head again.
> 
> I confirm this fixes the problem on my side.
> 
> Tested-by: Andrea Righi <andrea@betterlinux.com>

Great, thanks for verifying.

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
