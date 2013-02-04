Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 048D26B0005
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 07:27:46 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH?] Move ACPI device nodes under /sys/firmware/acpi (was: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug framework)
Date: Mon, 04 Feb 2013 13:34:02 +0100
Message-ID: <2107169.R5mOc9qh97@vostro.rjw.lan>
In-Reply-To: <20130204012447.GB6433@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com> <2806030.VWUMy6F7lm@vostro.rjw.lan> <20130204012447.GB6433@kroah.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Sunday, February 03, 2013 07:24:47 PM Greg KH wrote:
> On Sat, Feb 02, 2013 at 11:18:20PM +0100, Rafael J. Wysocki wrote:
> > On Saturday, February 02, 2013 09:15:37 PM Rafael J. Wysocki wrote:
> > > On Saturday, February 02, 2013 03:58:01 PM Greg KH wrote:
> > [...]
> > > 
> > > > I know it's more complicated with these types of devices, and I think we
> > > > are getting closer to the correct solution, I just don't want to ever
> > > > see duplicate devices in the driver model for the same physical device.
> > > 
> > > Do you mean two things based on struct device for the same hardware component?
> > > That's been happening already pretty much forever for every PCI device known
> > > to the ACPI layer, for PNP and many others.  However, those ACPI things are (or
> > > rather should be, but we're going to clean that up) only for convenience (to be
> > > able to see the namespace structure and related things in sysfs).  So the stuff
> > > under /sys/devices/LNXSYSTM\:00/ is not "real".  In my view it shouldn't even
> > > be under /sys/devices/ (/sys/firmware/acpi/ seems to be a better place for it),
> > > but that may be difficult to change without breaking user space (maybe we can
> > > just symlink it from /sys/devices/ or something).  And the ACPI bus type
> > > shouldn't even exist in my opinion.
> > 
> > Well, well.
> > 
> > In fact, the appended patch moves the whole ACPI device nodes tree under
> > /sys/firmware/acpi/ and I'm not seeing any negative consequences of that on my
> > test box (events work and so on).  User space is quite new on it, though, and
> > the patch is hackish.
> 
> Try booting a RHEL 5 image on this type of kernel, or some old Fedora
> releases, they were sensitive to changes in sysfs.

Well, I've found a machine where it causes problems to happen.

I'll try to add a symlink from /sys/devices to that and see what happens then.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
