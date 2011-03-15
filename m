Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 860AE8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 16:54:32 -0400 (EDT)
Date: Tue, 15 Mar 2011 13:53:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-Id: <20110315135334.36e29414.akpm@linux-foundation.org>
In-Reply-To: <bug-31142-10286@https.bugzilla.kernel.org/>
References: <bug-31142-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: avillaci@ceibo.fiec.espol.edu.ec
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 15 Mar 2011 15:55:52 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=31142
> 
>            Summary: Large write to USB stick freezes unrelated tasks for a
>                     long time
>            Product: IO/Storage
>            Version: 2.5
>     Kernel Version: 2.6.38-rc8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Block Layer
>         AssignedTo: axboe@kernel.dk
>         ReportedBy: avillaci@ceibo.fiec.espol.edu.ec
>         Regression: No
> 
> 
> Created an attachment (id=50902)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=50902)
> kernel backtraces from hung Eclipse task while writing to usb stick
> 
> System is Fedora 14 x86_64 with 4 GB RAM, running vanilla kernel 2.6.38-rc8.
> 
> I have a USB 2.0 high-speed memory stick with around 7.5 GB of space. Whenenver
> I write a large amount of data (several GBs of files) through any means (cp,
> nautilus GUI, etc), I notice some large applications that I consider unrelated
> to the I/O operation (Firefox web browser, Thunderbird email viewer, Eclipse
> IDE) may randomly freeze whenever I try to interact with them. I use Compiz,
> and I notice the apps getting grayed out, but I have also seen the freeze
> happening with Metacity and Gnome-shell, so I believe the window manager is
> irrelevant. Sometimes other smaller tasks (gnome-terminal, gedit) also freeze.
> For Eclipse, the hang also cause a series of kernel backtraces, attached to
> this report. The hang usually lasts for several tens of seconds, and may freeze
> and unfreeze several times while the file copying to USB takes place. All of
> the hung applications unfreeze themselves after write activity (as seen from
> the LED in the memory stick) ceases.
> 
> Reproducibility: always (with sufficiently large bulk write)
> To reproduce: 
> 1) have an usb stick with several GB of free space, with any filesystem (tried
> vfat and udf)
> 2) prepare several gb of files to copy from hard disk to usb stick
> 3) start large application (firefox, eclipse, or thunderbird)
> 4) check that application is responsive before file copy starts
> 5) insert usb stick and (auto)mount it. Previously started app is still
> responsive.
> 6) start file copy to usb stick with any command
> 7) attempt to interact with chosen application during the entirety of the file
> write
> Expected result: I/O to usb stick takes place in background, unrelated apps
> continue to be responsive in foreground.
> Actual result: some large tasks freeze for tens of seconds while write takes
> place.
> 
> Feel free to reassign this bug to a different category. It involves I/O, block,
> USB, and mmap.

rofl, will we ever fix this.

Please enable sysrq and do a sysrq-w when the tasks are blocked so we
can find where things are getting stuck.  Please avoid email client
wordwrapping when sending us the sysrq output.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
