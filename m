Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 8556A6B0074
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 17:03:54 -0500 (EST)
Date: Tue, 13 Nov 2012 14:03:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 50181] New: Memory usage doubles after more then 20 hours
 of uptime.
Message-Id: <20121113140352.4d2db9e8.akpm@linux-foundation.org>
In-Reply-To: <bug-50181-27@https.bugzilla.kernel.org/>
References: <bug-50181-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sukijaki@gmail.com
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue,  6 Nov 2012 15:11:48 +0000 (UTC)
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=50181
> 
>            Summary: Memory usage doubles after more then 20 hours of
>                     uptime.
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.7-rc3 and 3.7-rc4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: sukijaki@gmail.com
>         Regression: Yes
> 
> 
> Created an attachment (id=85721)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=85721)
> kernel config file
> 
> After 20 hours of uptime, memory usage starts going up. Normal usage for my
> system was around 2.5GB max with all my apps and services up and running. But
> with 3.7-rc3 and now -rc4 kernel, after more then 20 hours of uptime, it starts
> to going up. With kernel before 3.7-rc3, my machine could be up for 10 days and
> not go beyond 2.6GB memory usage.
> 
> If I start some app that uses a lot of memory, when there is already 4 or even
> 6GB used already, insted of freeing the memory, it starts to swap it, and
> everything slows down with a lot of iowait. 
> 
> Here is "free -m" output after 24 hours of uptime:
> 
> free -m
>              total       used       free     shared    buffers     cached
> Mem:          7989       7563        426          0        146       2772
> -/+ buffers/cache:       4643       3345
> Swap:         1953        688       1264
> 
> 
> I know that it is ok for memory to be used this much for buffers and cache, but
> it is not normal not to relase it when it is needed.
> 
> In attachment is my kernel config file.
> 

Sounds like a memory leak.

Please get the machine into this state and then send us

- the contents of /proc/meminfo

- the contents of /proc/slabinfo

- the contents of /proc/vmstat

- as root:

	dmesg -c
	echo m > /proc/sysrq-trigger
	dmesg

thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
