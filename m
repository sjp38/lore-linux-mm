Date: Sat, 19 Apr 2008 19:21:59 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080420022159.GA14037@suse.de>
References: <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com> <20080417233615.GA24508@us.ibm.com> <Pine.LNX.4.64.0804171639340.15173@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804171639340.15173@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 04:39:56PM -0700, Christoph Lameter wrote:
> On Thu, 17 Apr 2008, Nishanth Aravamudan wrote:
> 
> > That seems fine to me. I will work on it. However, as I mentioned in a
> > previous e-mail, the files in /sys/devices/system/node/node<nr>/
> > already violate the "one value per file" rule in several instances. I'm
> > guessing Greg won't want me moving the files and keeping that violation?
> 
> That violation is replicated in /proc/meminfo /proc/vmstat etc etc.

Those are /proc files, not sysfs files :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
