Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 7F6BE6B0072
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 13:43:08 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug framework
Date: Mon, 14 Jan 2013 19:48:58 +0100
Message-ID: <2154272.qDAyBlTr8z@vostro.rjw.lan>
In-Reply-To: <1358177628.14145.49.camel@misato.fc.hp.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com> <5036592.TuXAnGzk4M@vostro.rjw.lan> <1358177628.14145.49.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Monday, January 14, 2013 08:33:48 AM Toshi Kani wrote:
> On Fri, 2013-01-11 at 22:23 +0100, Rafael J. Wysocki wrote:
> > On Thursday, January 10, 2013 04:40:19 PM Toshi Kani wrote:
> > > Added include/linux/sys_hotplug.h, which defines the system device
> > > hotplug framework interfaces used by the framework itself and
> > > handlers.
> > > 
> > > The order values define the calling sequence of handlers.  For add
> > > execute, the ordering is ACPI->MEM->CPU.  Memory is onlined before
> > > CPU so that threads on new CPUs can start using their local memory.
> > > The ordering of the delete execute is symmetric to the add execute.
> > > 
> > > struct shp_request defines a hot-plug request information.  The
> > > device resource information is managed with a list so that a single
> > > request may target to multiple devices.
> > > 
>  :
> > > +
> > > +struct shp_device {
> > > +	struct list_head	list;
> > > +	struct device		*device;
> > > +	enum shp_class		class;
> > > +	union shp_dev_info	info;
> > > +};
> > > +
> > > +/*
> > > + * Hot-plug request
> > > + */
> > > +struct shp_request {
> > > +	/* common info */
> > > +	enum shp_operation	operation;	/* operation */
> > > +
> > > +	/* hot-plug event info: only valid for hot-plug operations */
> > > +	void			*handle;	/* FW handle */
> > 
> > What's the role of handle here?
> 
> On ACPI-based platforms, the handle keeps a notified ACPI handle when a
> hot-plug request is made.  ACPI bus handlers, acpi_add_execute() /
> acpi_del_execute(), then scans / trims ACPI devices from the handle.

OK, so this is ACPI-specific and should be described as such.

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
