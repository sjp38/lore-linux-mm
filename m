Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5775E6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 07:23:07 -0400 (EDT)
Date: Thu, 2 Jun 2011 12:23:01 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 35762] New: Kernel panics on do_raw_spin_lock()
Message-ID: <20110602112301.GH7019@csn.ul.ie>
References: <bug-35762-10286@https.bugzilla.kernel.org/>
 <20110601165026.16ddbcbb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110601165026.16ddbcbb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, bryan.christ@gmail.com

On Wed, Jun 01, 2011 at 04:50:26PM -0700, Andrew Morton wrote:
> On Tue, 24 May 2011 20:06:01 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=35762
> > 
> >            Summary: Kernel panics on do_raw_spin_lock()
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 2.6.38.6-26.rc1.fc14.x86_64
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: bryan.christ@gmail.com
> >         Regression: No
> > 
> > 
> > Kernel seems to frequently panic with RIP at do_raw_spin_lock().  I
> > assume this might be vma related since the trace often implicates
> > vma_merge() and friends.
> > 
> > Screenshots of panic:
> > 
> > http://www.mediafire.com/imageview.php?quickkey=hnd1dedna9bed65
> > http://www.mediafire.com/imageview.php?quickkey=n86366d44i7mlx4
> > http://www.mediafire.com/imageview.php?quickkey=0sgzfd91dvl3jhl
> > http://www.mediafire.com/imageview.php?quickkey=zwly9x5c4zg28dn
> 
> hm, those photos aren't terribly useful.  They seem to be pointing at
> the compaction code.
> 

It's possible but I'm agreed that the photos aren't terribly useful. It
would be preferable to see the first oops where as this appears to be a
second or third oops.

Also, I note this is a Fedora kernel. Is the bug readily reproducible? 
If so, would you be willing to verify the problem happens with 2.6.38.7?
What are the reproduction steps?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
