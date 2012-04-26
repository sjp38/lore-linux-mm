Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id EB1566B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 17:53:01 -0400 (EDT)
Date: Thu, 26 Apr 2012 17:52:57 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.4-rc4 oom killer out of control.
Message-ID: <20120426215257.GA12908@redhat.com>
References: <20120426193551.GA24968@redhat.com>
 <alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, Apr 26, 2012 at 02:40:48PM -0700, David Rientjes wrote:
 > On Thu, 26 Apr 2012, Dave Jones wrote:
 > 
 > > On a test machine that was running my system call fuzzer, I just saw
 > > the oom killer take out everything but the process that was doing all
 > > the memory exhausting.
 > > 
 > 
 > Would it be possible to try the below patch?  It should kill the thread 
 > using the most memory (which happens to only be a couple more megabytes on 
 > your system), but it might just delay the inevitable since the system is 
 > still in a pretty bad state.
 > 
 > KOSAKI-san suggested doing this before and I think it's the best direction 
 > to go in anyway.

Sure, I'll give it a shot when I reboot.

However, see my follow-up message. I think there are two bugs here.
1) The over-aggressive oom-killer, and 2) ksmd going mental.

/sys/kernel/mm/ksm/full_scans is increasing constantly

full_scans: 146370
pages_shared: 1
pages_sharing: 4
pages_to_scan: 1250
pages_unshared: 867
pages_volatile: 1
run: 1
sleep_millisecs: 20

everything in /sys/kernel/mm/hugepages/hugepages-2048kB, is 0.

/sys/kernel/mm/transparent_hugepage/khugepaged:
alloc_sleep_millisecs  60000
defrag  1
full_scans  15
max_ptes_none 511 
pages_collapsed  6
pages_to_scan  4096
scan_sleep_millisecs 10000


	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
