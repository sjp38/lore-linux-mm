Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3LGiErH026515
	for <linux-mm@kvack.org>; Mon, 21 Apr 2008 12:44:14 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3LGg8En215796
	for <linux-mm@kvack.org>; Mon, 21 Apr 2008 12:42:08 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3LGfvsE015643
	for <linux-mm@kvack.org>; Mon, 21 Apr 2008 12:41:58 -0400
Date: Mon, 21 Apr 2008 09:41:46 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080421164146.GA32429@us.ibm.com>
References: <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com> <20080417233615.GA24508@us.ibm.com> <Pine.LNX.4.64.0804171639340.15173@schroedinger.engr.sgi.com> <20080420022159.GA14037@suse.de> <Pine.LNX.4.64.0804202305470.13872@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804202305470.13872@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Greg KH <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 20.04.2008 [23:06:48 -0700], Christoph Lameter wrote:
> On Sat, 19 Apr 2008, Greg KH wrote:
> 
> > > That violation is replicated in /proc/meminfo /proc/vmstat etc etc.
> > 
> > Those are /proc files, not sysfs files :)
> 
> Hmmm.. Maybe we need to have /proc/node<x>/meminfo etc that replicates
> the /proc content for each node? Otherwise this cannot be symmetric
> because the different mount points have different requirements on how
> the output should look like.

But the memory info has nothing to do with process specific information,
which is what "new" /proc files should contain (or maybe I'm
mis-remembering).

The current location (/sys/devices/system/node) reflects that memory is
tied to system devices called "nodes"; I'm not entirely convinced we'd
want to change that?  Especially, as Greg noted, it's easier to obtain
the information we want off a sysdev, rather than the raw kobject.

While I understand the desire to maintain sanity for sysfs files,
perhaps the meminfo files (and numastat, etc) are just special, in that
they only make sense as a collective (the snapshot mentioned earlier in
this thread) -- to get a view of the component (memory, NUMA statistics,
etc) as a whole.

In that sense, perhaps the sysfs notion should be extended to "One
logical value per file", where logical is defined as the minimum atomic
information needed by the user [1]? Or perhaps sysfs just isn't the best
place for this information, I don't know. I don't believe I am the
person to make that call.

Thanks,
Nish

[1] That would allow files like available_clocksource not to seem like
violators of the sysfs rule:

$ sudo cat /sys/devices/system/clocksource/clocksource0/available_clocksource
hpet acpi_pm pit jiffies tsc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
