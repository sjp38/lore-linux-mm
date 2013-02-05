Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id B702C6B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 16:07:33 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug framework
Date: Tue, 05 Feb 2013 22:13:49 +0100
Message-ID: <1692384.YXBH6mB6ZX@vostro.rjw.lan>
In-Reply-To: <20130205183948.GA19026@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com> <4225828.6MQHJn7Yzr@vostro.rjw.lan> <20130205183948.GA19026@kroah.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Tuesday, February 05, 2013 10:39:48 AM Greg KH wrote:
> On Tue, Feb 05, 2013 at 12:11:17PM +0100, Rafael J. Wysocki wrote:
> > On Monday, February 04, 2013 04:04:47 PM Greg KH wrote:
> > > On Tue, Feb 05, 2013 at 12:52:30AM +0100, Rafael J. Wysocki wrote:
> > > > You'd probably never try to hot-remove a disk before unmounting filesystems
> > > > mounted from it or failing it as a RAID component and nobody sane wants the
> > > > kernel to do things like that automatically when the user presses the eject
> > > > button.  In my opinion we should treat memory eject, or CPU package eject, or
> > > > PCI host bridge eject in exactly the same way: Don't eject if it is not
> > > > prepared for ejecting in the first place.
> > > 
> > > Bad example, we have disks hot-removed all the time without any
> > > filesystems being unmounted, and have supported this since the 2.2 days
> > > (although we didn't get it "right" until 2.6.)
> > 
> > I actually don't think it is really bad, because it exposes the problem nicely.
> > 
> > Namely, there are two arguments that can be made here.  The first one is the
> > usability argument: Users should always be allowed to do what they want,
> > because it is [explicit content] annoying if software pretends to know better
> > what to do than the user (it is a convenience argument too, because usually
> > it's *easier* to allow users to do what they want).  The second one is the
> > data integrity argument: Operations that may lead to data loss should never
> > be carried out, because it is [explicit content] disappointing to lose valuable
> > stuff by a stupid mistake if software allows that mistake to be made (that also
> > may be costly in terms of real money).
> > 
> > You seem to believe that we should always follow the usability argument, while
> > Toshi seems to be thinking that (at least in the case of the "system" devices),
> > the data integrity argument is more important.  They are both valid arguments,
> > however, and they are in conflict, so this is a matter of balance.
> > 
> > You're saying that in the case of disks we always follow the usability argument
> > entirely.  I'm fine with that, although I suspect that some people may not be
> > considering this as the right balance.
> > 
> > Toshi seems to be thinking that for the hotplug of memory/CPUs/host bridges we
> > should always follow the data integrity argument entirely, because the users of
> > that feature value their data so much that they pretty much don't care about
> > usability.  That very well may be the case, so I'm fine with that too, although
> > I'm sure there are people who'll argue that this is not the right balance
> > either.
> > 
> > Now, the point is that we *can* do what Toshi is arguing for and that doesn't
> > seem to be overly complicated, so my question is: Why don't we do that, at
> > least to start with?  If it turns out eventually that the users care about
> > usability too, after all, we can add a switch to adjust things more to their
> > liking.  Still, we can very well do that later.
> 
> Ok, I'd much rather deal with reviewing actual implementations than
> talking about theory at this point in time, so let's see what you all
> can come up with next and I'll be glad to review it.

Sure, thanks a lot for your comments so far!

Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
