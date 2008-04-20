Date: Sat, 19 Apr 2008 19:24:21 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080420022421.GB14037@suse.de>
References: <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com> <20080417233615.GA24508@us.ibm.com> <Pine.LNX.4.64.0804171639340.15173@schroedinger.engr.sgi.com> <20080418060404.GA5807@us.ibm.com> <20080418172730.GA12798@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080418172730.GA12798@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 18, 2008 at 10:27:30AM -0700, Nishanth Aravamudan wrote:
> On 17.04.2008 [23:04:04 -0700], Nishanth Aravamudan wrote:
> > On 17.04.2008 [16:39:56 -0700], Christoph Lameter wrote:
> > > On Thu, 17 Apr 2008, Nishanth Aravamudan wrote:
> > > 
> > > > That seems fine to me. I will work on it. However, as I mentioned in a
> > > > previous e-mail, the files in /sys/devices/system/node/node<nr>/
> > > > already violate the "one value per file" rule in several instances. I'm
> > > > guessing Greg won't want me moving the files and keeping that violation?
> > > 
> > > That violation is replicated in /proc/meminfo /proc/vmstat etc etc.
> > 
> > Right, but /proc doesn't have such a restriction (the "one value per
> > file" rule). I'm not sure how the meminfo, etc. files in sysfs got put
> > in past Greg, but that's how it is :)
> 
> Greg, can you give any insight here? Are we better off leaving the files
> in question in /sys/devices/system/node/node<nr>/{meminfo,numastat,etc}
> since they are part of the ABI there and already violate the rules for
> sysfs? Or can we move them to /sys/kernel and continue to violate the
> rules? In this case, I don't see any way to provide a "snapshot" of the
> system's memory information without all the values being in one file?

Yeah, the "snapshot" issue is what allows those values all to be present
at once.

As for where to place them, are there any tools out there that are
expecting the current file locations?  If so, can they work if they are
in both places?

If you think they should be moved, I'll defer to your judgement, but it
will be a bit harder, as you will be working with "raw" kobjects in that
case, not the sysdev structures, which do make things a bit easier for
you.

sorry for the delay, am traveling...

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
