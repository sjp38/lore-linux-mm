Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0E76B0023
	for <linux-mm@kvack.org>; Thu,  5 May 2011 17:50:00 -0400 (EDT)
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [140.211.169.55])
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p45Lnv2X004738
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 5 May 2011 14:49:57 -0700
Received: from akpm.mtv.corp.google.com (localhost [127.0.0.1])
	by imap1.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with SMTP id p45LhhH1004740
	for <linux-mm@kvack.org>; Thu, 5 May 2011 14:43:43 -0700
Date: Thu, 5 May 2011 14:43:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 34132] New: System is unresponsive while using
 dd to copy DVD ISO to USB stick/key
Message-Id: <20110505144343.7c98bfce.akpm@linux-foundation.org>
In-Reply-To: <bug-34132-10286@https.bugzilla.kernel.org/>
References: <bug-34132-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

In case anyone was wondering if we've stopped sucking yet.

On Sat, 30 Apr 2011 16:12:15 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=34132
> 
>            Summary: System is unresponsive while using dd to copy DVD ISO
>                     to USB stick/key
>            Product: IO/Storage
>            Version: 2.5
>     Kernel Version: 2.6.38.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: io_other@kernel-bugs.osdl.org
>         ReportedBy: jlp.bugs@gmail.com
>         Regression: No
> 
> 
> When I use
> 
> dd if=<some_iso_file> of=<device_of_usb_key>
> 
> The system becomes very unresponsive. X is almost completely unusable, maybe
> you can move a mouse for some time but click do nothing. Even togling the Caps
> Lock doesn't do anything. Trying to SSH is also almost impossible during this.
> System is like this all the time while using the dd command. After it finishes
> system again becomes responsive. I've noticed this on two of my computers:
> 1: AMD Athlon 64 3000+, 2 GB of memory, kernel 2.6.38.2
> 2: AMD Athlon II P320 Dual-Core, 4 GB of memory, kernel 2.6.39-rc2
> The USB key is this one:
> http://www.takems.com/products.php?categ=usb&prod=MEM-Drive_Easy_II
> 
> What I expected was that the doing dd wouldn't have a noticable impact on
> responsivness of the rest of the system.
> 

Maybe it's not VM-related.  This time.  Maybe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
