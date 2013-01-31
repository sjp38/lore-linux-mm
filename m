Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 8A39A6B0007
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 09:52:45 -0500 (EST)
Message-ID: <1359643356.15120.158.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device
 hotplug framework
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 31 Jan 2013 07:42:36 -0700
In-Reply-To: <20130131052448.GC3228@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
	 <5036592.TuXAnGzk4M@vostro.rjw.lan>
	 <1358177628.14145.49.camel@misato.fc.hp.com>
	 <2154272.qDAyBlTr8z@vostro.rjw.lan>
	 <1358190124.14145.79.camel@misato.fc.hp.com>
	 <20130130044859.GD30002@kroah.com>
	 <1359594912.15120.85.camel@misato.fc.hp.com>
	 <20130131052448.GC3228@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "bhelgaas@google.com" <bhelgaas@google.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "srivatsa.bhat@linux.vnet.ibm.com" <srivatsa.bhat@linux.vnet.ibm.com>

On Thu, 2013-01-31 at 05:24 +0000, Greg KH wrote:
> On Wed, Jan 30, 2013 at 06:15:12PM -0700, Toshi Kani wrote:
> > > Please make it a "real" pointer, and not a void *, those shouldn't be
> > > used at all if possible.
> > 
> > How about changing the "void *handle" to acpi_dev_node below?   
> > 
> >    struct acpi_dev_node    acpi_node;
> > 
> > Basically, it has the same challenge as struct device, which uses
> > acpi_dev_node as well.  We can add other FW node when needed (just like
> > device also has *of_node).
> 
> That sounds good to me.

Great!  Thanks Greg,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
