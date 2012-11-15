Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 013D16B005A
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 09:05:55 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so836135bkc.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 06:05:54 -0800 (PST)
Message-ID: <1352988349.6409.4.camel@c2d-desktop.mypicture.info>
Subject: Re: [Bug 50181] New: Memory usage doubles after more then 20 hours
 of uptime.
From: Milos Jakovljevic <sukijaki@gmail.com>
Date: Thu, 15 Nov 2012 15:05:49 +0100
In-Reply-To: <20121113140352.4d2db9e8.akpm@linux-foundation.org>
References: <bug-50181-27@https.bugzilla.kernel.org/>
	 <20121113140352.4d2db9e8.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Tue, 2012-11-13 at 14:03 -0800, Andrew Morton wrote: 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue,  6 Nov 2012 15:11:48 +0000 (UTC)
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=50181
> > 
> >            Summary: Memory usage doubles after more then 20 hours of
> >                     uptime.
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 3.7-rc3 and 3.7-rc4
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: sukijaki@gmail.com
> >         Regression: Yes
> > 
> > 
> > Created an attachment (id=85721)
> >  --> (https://bugzilla.kernel.org/attachment.cgi?id=85721)
> > kernel config file
> > 
> > After 20 hours of uptime, memory usage starts going up. Normal usage for my
> > system was around 2.5GB max with all my apps and services up and running. But
> > with 3.7-rc3 and now -rc4 kernel, after more then 20 hours of uptime, it starts
> > to going up. With kernel before 3.7-rc3, my machine could be up for 10 days and
> > not go beyond 2.6GB memory usage.
> > 
> > If I start some app that uses a lot of memory, when there is already 4 or even
> > 6GB used already, insted of freeing the memory, it starts to swap it, and
> > everything slows down with a lot of iowait. 
> > 
> > Here is "free -m" output after 24 hours of uptime:
> > 
> > free -m
> >              total       used       free     shared    buffers     cached
> > Mem:          7989       7563        426          0        146       2772
> > -/+ buffers/cache:       4643       3345
> > Swap:         1953        688       1264
> > 
> > 
> > I know that it is ok for memory to be used this much for buffers and cache, but
> > it is not normal not to relase it when it is needed.
> > 
> > In attachment is my kernel config file.
> > 
> 
> Sounds like a memory leak.
> 
> Please get the machine into this state and then send us
> 
> - the contents of /proc/meminfo
> 
> - the contents of /proc/slabinfo
> 
> - the contents of /proc/vmstat
> 
> - as root:
> 
> 	dmesg -c
> 	echo m > /proc/sysrq-trigger
> 	dmesg
> 
> thanks.

Here is the requested content:

free -m: http://pastebin.com/vb878a9Y
cat /proc/meminfo : http://pastebin.com/zUDFcYEW
cat /proc/slabinfo : http://pastebin.com/kswsJ7Hk
cat /proc/vmstat : http://pastebin.com/wUebJqJe

dmesg -c : http://pastebin.com/f7cTu8Wv

echo m > /proc/sysrq-trigger && dmesg : http://pastebin.com/p68DcHUy

And here are also files with that content:
http://ubuntuone.com/5GUVahBTiZRP0QjQdP3gkQ




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
