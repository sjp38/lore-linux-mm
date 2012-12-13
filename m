Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 871546B0099
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 19:48:38 -0500 (EST)
Message-ID: <1355359176.18964.41.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH 00/11] Hot-plug and Online/Offline framework
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 12 Dec 2012 17:39:36 -0700
In-Reply-To: <20121212235657.GD22764@kroah.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
	 <20121212235657.GD22764@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: rjw@sisk.pl, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Wed, 2012-12-12 at 15:56 -0800, Greg KH wrote:
> On Wed, Dec 12, 2012 at 04:17:12PM -0700, Toshi Kani wrote:
> > This patchset is an initial prototype of proposed hot-plug framework
> > for design review.  The hot-plug framework is designed to provide 
> > the common framework for hot-plugging and online/offline operations
> > of system devices, such as CPU, Memory and Node.  While this patchset
> > only supports ACPI-based hot-plug operations, the framework itself is
> > designed to be platform-neural and can support other FW architectures
> > as necessary.
> > 
> > The patchset has not been fully tested yet, esp. for memory hot-plug.
> > Any help for testing will be very appreciated since my test setup
> > is limited.
> > 
> > The patchset is based on the linux-next branch of linux-pm.git tree.
> > 
> > Overview of the Framework
> > =========================
> 
> <snip>
> 
> Why all the new framework, doesn't the existing bus infrastructure
> provide everything you need here?  Shouldn't you just be putting your
> cpus and memory sticks on a bus and handle stuff that way?  What makes
> these types of devices so unique from all other devices that Linux has
> been handling in a dynamic manner (i.e. hotplugging them) for many many
> years?
> 
> Why are you reinventing the wheel?

Good question.  Yes, USB and PCI hotplug operate based on their bus
structures.  USB and PCI cards only work under USB and PCI bus
controllers.  So, their framework can be composed within the bus
structures as you pointed out.

However, system devices such CPU and memory do not have their standard
bus.  ACPI allows these system devices to be enumerated, but it does not
make ACPI as the HW bus hierarchy for CPU and memory, unlike PCI and
USB.  Therefore, CPU and memory modules manage CPU and memory outside of
ACPI.  This makes sense because CPU and memory can be used without ACPI.

This leads us an issue when we try to manage system device hotplug
within ACPI, because ACPI does not control everything.  This patchset
provides a common hotplug framework for system devices, which both ACPI
and non-ACPI modules (i.e. CPU and memory modules) can participate and
are coordinated for their hotplug operations.  This is analogous to the
boot-up sequence, which ACPI and non-ACPI modules can participate to
enable CPU and memory.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
