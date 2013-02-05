Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 764A86B00B5
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 19:02:42 -0500 (EST)
Received: by mail-ia0-f175.google.com with SMTP id r4so8816499iaj.34
        for <linux-mm@kvack.org>; Mon, 04 Feb 2013 16:02:41 -0800 (PST)
Date: Mon, 4 Feb 2013 16:04:47 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug
 framework
Message-ID: <20130205000447.GA21782@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
 <5598823.8hjkkMP1h9@vostro.rjw.lan>
 <1360016009.23410.213.camel@misato.fc.hp.com>
 <7003418.onqVlaaHJS@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7003418.onqVlaaHJS@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Toshi Kani <toshi.kani@hp.com>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Tue, Feb 05, 2013 at 12:52:30AM +0100, Rafael J. Wysocki wrote:
> You'd probably never try to hot-remove a disk before unmounting filesystems
> mounted from it or failing it as a RAID component and nobody sane wants the
> kernel to do things like that automatically when the user presses the eject
> button.  In my opinion we should treat memory eject, or CPU package eject, or
> PCI host bridge eject in exactly the same way: Don't eject if it is not
> prepared for ejecting in the first place.

Bad example, we have disks hot-removed all the time without any
filesystems being unmounted, and have supported this since the 2.2 days
(although we didn't get it "right" until 2.6.)

PCI Host bridge eject is the same as PCI eject today, the user asks us
to do it, and we can not fail it from happening.  We also can have them
removed without us being told about it in the first place, and can
properly clean up from it all.

> And if you think about it, that makes things *massively* simpler, because now
> the kernel doesn't heed to worry about all of those "synchronous removal"
> scenarions that very well may involve every single device in the system and
> the whole problem is nicely split into several separate "implement
> offline/online" problems that are subsystem-specific and a single
> "eject if everything relevant is offline" problem which is kind of trivial.
> Plus the one of exposing information to user space, which is separate too.
> 
> Now, each of them can be worked on separately, *tested* separately and
> debugged separately if need be and it is much easier to isolate failures
> and so on.

So you are agreeing with me in that we can not fail hot removing any
device, nice :)

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
