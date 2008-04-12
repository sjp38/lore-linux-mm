Date: Sat, 12 Apr 2008 11:41:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080412094118.GA7708@wotan.suse.de>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080411235648.GA13276@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, wli@holomorphy.com, clameter@sgi.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 11, 2008 at 04:56:48PM -0700, Greg KH wrote:
> On Fri, Apr 11, 2008 at 04:49:13PM -0700, Nishanth Aravamudan wrote:
> > /sys/devices/system/node represents the current NUMA configuration of
> > the machine, but is undocumented in the ABI files. Add bare-bones
> > documentation for these files.
> > 
> > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > 
> > ---
> > Greg, is something like this what you'd want?
> 
> Yes it is, thanks for doing it.

Can you comment on the aspect of configuring various kernel hugetlb 
configuration parameters? Especifically, what directory it should go in?
IMO it should be /sys/kernel/*

/sys/devices/system/etc should be fine eg. for showing how many pages are
available in a given node, or what kinds of TLBs the CPU has, but I would
have thought that configuring the kernel's hugetlb settings should be
in /sys/kernel.

Then again, I can't say I'm up to speed on sysfs policy so the main thing
I care about is that it is consistent and correct.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
