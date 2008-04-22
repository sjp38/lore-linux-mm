Date: Tue, 22 Apr 2008 07:14:47 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080422051447.GI21993@wotan.suse.de>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Greg KH <gregkh@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 04:22:17PM -0700, Christoph Lameter wrote:
> On Thu, 17 Apr 2008, Nishanth Aravamudan wrote:
> 
> > > Do you see a particular more-sysfs-way here, Greg?
> > 
> > So I've received no comments yet? Perhaps I should leave things the way
> > they are (per-node files in /sys/devices/system/node) and add
> > nr_hugepages to /sys/kernel?
> 
> The strange location of the node directories has always irked me.
> > 
> > Do we want to put it in a subdirectory of /sys/kernel? What should the
> > subdir be called? "hugetlb" (refers to the implementation?) or
> > "hugepages"?
> 
> How about:
> 
> /sys/kernel/node<nr>/<node specific setting/status files> ?

I don't like /sys/kernel/node :P

Under /sys/kernel, we should have parameters to set and query various
kernel functionality. Control of the kernel software implementation. I
think this is pretty well agreed (although there are maybe grey areas I
guess)

So anyway, underneath that directory, we should have more subdirectories
grouping subsystems or sumilar functionality. We aren't tuning node,
but hugepages subsystem.

/sys/kernel/huge{tlb|pages}/

Under that directory could be global settings as well as per node settings
or subdirectories and so on. The layout should be similar to /proc/sys/*
IMO. Actually it should be much neater since we have some hindsight, but
unfortunately it is looking like it is actually messier ;)

Let's really try to put some thought into new sysfs locations. Not just
will it work, but is it logical and will it work tomorrow...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
