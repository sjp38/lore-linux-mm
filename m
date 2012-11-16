Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 95BBC6B0068
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:46:25 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so496960eaa.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 10:46:21 -0800 (PST)
Message-ID: <1353091574.23064.14.camel@c2d-desktop.mypicture.info>
Subject: Re: [Bug 50181] New: Memory usage doubles after more then 20 hours
 of uptime.
From: Milos Jakovljevic <sukijaki@gmail.com>
Date: Fri, 16 Nov 2012 19:46:14 +0100
In-Reply-To: <50A68718.3070002@linux.vnet.ibm.com>
References: <bug-50181-27@https.bugzilla.kernel.org/>
	 <20121113140352.4d2db9e8.akpm@linux-foundation.org>
	 <1352988349.6409.4.camel@c2d-desktop.mypicture.info>
	 <20121115141258.8e5cc669.akpm@linux-foundation.org>
	 <1353021103.6409.31.camel@c2d-desktop.mypicture.info>
	 <50A68718.3070002@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Fri, 2012-11-16 at 10:34 -0800, Dave Hansen wrote: 
> On 11/15/2012 03:11 PM, Milos Jakovljevic wrote:
> > Or maybe, it is just some problem with nvidia blob and 3.7 kernel
> > loosing VM_RELEASE  (in a blob's mmap.c it was replaced with
> > VM_DONTEXPAND | VM_DONTDUMP ).  - or maybe I'm just saying nonsense
> > here.
> 
> I'm using Intel graphics, so it's not nvidia related for me, at least.
> 
> I've been recording a bunch of gunk from /proc once a minute for the
> past 16 hours or so.  I've grepped some of it in to a log file (but I've
> got a *LOT* more than this):
> 
> 	http://sr71.net/~dave/linux/leak-20121113/log.1353087988.txt.gz
> 
> From meminfo, it shows MemFree/Buffers/Cached/AnonPages/Slab/PageTables,
> and their sum.  That should capture _most_ of the memory use on the
> system, and if we see that sum going down, it's probably a sign of the
> leak, especially when we see a trend over a long period.  The file is in
> roughly this format, if anyone cares:
> 
> 	<nr/date>  <meminfo fields> sums:  <sum fields> <delta>
> 
> The system in question is my laptop.  What I can tell is that it doesn't
> leak much when I'm not using it.  But, it's leaking pretty steadily
> since I started using the system today (~6am in the logs).  It
> _averages_ leaking about 400kB/minute when idle and almost 9MB/minute
> when in active use.
> 
> I've tried to provoke the leak doing specific things like large
> downloads, kernel compiles, watching video, alloc'ing a bunch of
> transparent huge pages, then exiting...  No smoking gun so far.
> 
> Anybody have ideas what to try next or want to poke holes in my
> statistics? :)
> 

For me, it mostly happens over night, when there is only tvtime and
deluge active (and rest of the programs are open but I don't use them -
firefox, evolution and pidgin). 
Only ones it happened while I was on the PC doing something. It was
fresh after reboot, and I was  restarting  Firefox, 10 or more times (I
was experimenting with addons).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
