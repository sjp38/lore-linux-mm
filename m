Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 75BE76B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 15:57:32 -0400 (EDT)
Date: Mon, 22 Aug 2011 15:56:51 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing and reading
 from multiple drives decreases by 40% when going from Linux Kernel 2.6.36.4
 to 2.6.37 (and beyond)
Message-ID: <20110822195651.GB15087@redhat.com>
References: <bug-41552-10286@https.bugzilla.kernel.org/>
 <20110822122443.c04839c8.akpm@linux-foundation.org>
 <BLU165-W518E4E2216B3E0FE0248EFFF2F0@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLU165-W518E4E2216B3E0FE0248EFFF2F0@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Petersen <mpete_06@hotmail.com>
Cc: akpm@linux-foundation.org, bugme-daemon@bugzilla.kernel.org, axboe@kernel.dk, linux-mm@kvack.org, linux-scsi@vger.kernel.org

On Mon, Aug 22, 2011 at 02:49:56PM -0500, Mark Petersen wrote:
> 
> The majority of the slowdown we found is coming during the writing as we were doing limited reading for the purpose of the testing.  It may be that it happens in both areas, but we did not do extensive testing with the reading portion of it.

What kind of writes these are? Write slowdown by 40%. Somehow now a days
barriers/flush/fua comes to my mind. Any changes there w.r.t your setup?

Recently Jeff moyer and Mike Snitzer had discovered and fixed a slowdown
in a dm-multipath and disks not having write caches. I guess that's not
your setup. Though mentioning it does not harm.

Thanks
Vivek

 
> 
> > Date: Mon, 22 Aug 2011 12:24:43 -0700
> > From: akpm@linux-foundation.org
> > To: mpete_06@hotmail.com
> > CC: bugme-daemon@bugzilla.kernel.org; axboe@kernel.dk; vgoyal@redhat.com; linux-mm@kvack.org; linux-scsi@vger.kernel.org
> > Subject: Re: [Bugme-new] [Bug 41552] New: Performance of writing and reading from multiple drives decreases by 40% when going from Linux Kernel 2.6.36.4 to 2.6.37 (and beyond)
> > 
> > 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Mon, 22 Aug 2011 15:20:41 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=41552
> > > 
> > >            Summary: Performance of writing and reading from multiple
> > >                     drives decreases by 40% when going from Linux Kernel
> > >                     2.6.36.4 to 2.6.37 (and beyond)
> > >            Product: IO/Storage
> > >            Version: 2.5
> > >     Kernel Version: 2.6.37
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: SCSI
> > >         AssignedTo: linux-scsi@vger.kernel.org
> > >         ReportedBy: mpete_06@hotmail.com
> > >         Regression: No
> > > 
> > > 
> > > We have an application that will write and read from every sector on a drive. 
> > > The application can perform these tasks on multiple drives at the same time. 
> > > It is designed to run on top of the Linux Kernel, which we periodically update
> > > so that we can get the latest device drivers.  When performing the last update
> > > from 2.6.33.2 to 2.6.37, we found that the performance of a set of drives
> > > decreased by some 40% (took 3 hours and 11 minutes to write and read from 5
> > > drives on 2.6.37 versus 2 hours and 12 minutes on 2.6.33.3).  I was able to
> > > determine that the issue was in the 2.6.37 Kernel as I was able to run it with
> > > the 2.6.36.4 kernel, and it had the better performance.   After seeing that I/O
> > > throttling was introduced in the 2.6.37 Kernel, I naturally suspected that. 
> > > However, by default, all the throttling was turned off (I attached the actual
> > > .config that was used to build the kernel).  I then tried to turn on the
> > > throttling and set it to a high number to see what would happen.  When I did
> > > that, I was able to reduce the time from 3 hours and 11 minutes to 2 hours and
> > > 50 minutes.  There seems to be something there that changed that is impacting
> > > performance on multiple drives.  When we do this same test with only one drive,
> > > the performance is identical between the systems.  This issue still occurs on
> > > Kernel 3.0.2.
> > > 
> > 
> > Are you able to determine whether this regression is due to slower
> > reading, to slower writing or to both?
> > 
> > Thanks.
>  		 	   		  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
