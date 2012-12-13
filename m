Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 335626B0044
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 11:39:55 -0500 (EST)
Message-ID: <1355416251.18964.170.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH 02/11] drivers/base: Add hotplug framework code
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 13 Dec 2012 09:30:51 -0700
In-Reply-To: <20121213042437.GA14240@kroah.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
	 <1355354243-18657-3-git-send-email-toshi.kani@hp.com>
	 <20121212235418.GB22764@kroah.com>
	 <1355371365.18964.89.camel@misato.fc.hp.com>
	 <20121213042437.GA14240@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: "rjw@sisk.pl" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "bhelgaas@google.com" <bhelgaas@google.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "srivatsa.bhat@linux.vnet.ibm.com" <srivatsa.bhat@linux.vnet.ibm.com>

On Thu, 2012-12-13 at 04:24 +0000, Greg KH wrote:
> On Wed, Dec 12, 2012 at 09:02:45PM -0700, Toshi Kani wrote:
> > On Wed, 2012-12-12 at 15:54 -0800, Greg KH wrote:
> > > On Wed, Dec 12, 2012 at 04:17:14PM -0700, Toshi Kani wrote:
> > > > Added hotplug.c, which is the hotplug framework code.
> > > 
> > > Again, better naming please.
> > 
> > Yes, I will change it to be more specific, something like
> > "sys_hotplug.c".
> 
> Ugh, what's wrong with just a simple "system_bus.c" or something like
> that, and then put all of the needed system bus logic in there and tie
> the cpus and other sysdev code into that?

The issue is that the framework does not provide the system bus
structure.  This is because the system bus structure is not used for CPU
and memory initialization at boot (as I explained in my other email).
The framework manages the calling sequence of hotplug operations, which
is similar to the boot sequence managed by start_kernel(),
kernel_init(), do_initcalls(), etc.  In such sense, this file might not
be a good fit for drivers/base, but I could not find a better place for
it.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
