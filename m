Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7E36B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 19:51:52 -0400 (EDT)
Date: Wed, 1 Jun 2011 16:50:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 35762] New: Kernel panics on
 do_raw_spin_lock()
Message-Id: <20110601165026.16ddbcbb.akpm@linux-foundation.org>
In-Reply-To: <bug-35762-10286@https.bugzilla.kernel.org/>
References: <bug-35762-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, bryan.christ@gmail.com

On Tue, 24 May 2011 20:06:01 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=35762
> 
>            Summary: Kernel panics on do_raw_spin_lock()
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.38.6-26.rc1.fc14.x86_64
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: bryan.christ@gmail.com
>         Regression: No
> 
> 
> Kernel seems to frequently panic with RIP at do_raw_spin_lock().  I
> assume this might be vma related since the trace often implicates
> vma_merge() and friends.
> 
> Screenshots of panic:
> 
> http://www.mediafire.com/imageview.php?quickkey=hnd1dedna9bed65
> http://www.mediafire.com/imageview.php?quickkey=n86366d44i7mlx4
> http://www.mediafire.com/imageview.php?quickkey=0sgzfd91dvl3jhl
> http://www.mediafire.com/imageview.php?quickkey=zwly9x5c4zg28dn

hm, those photos aren't terribly useful.  They seem to be pointing at
the compaction code.

Maybe using the pause_on_oops kernel command line option
(Documentation/kernel-parameters.txt) will prevent the frist part of
the first oops from scrolling off the screen?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
