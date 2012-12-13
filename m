Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A2C036B002B
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 23:22:09 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so546244dak.14
        for <linux-mm@kvack.org>; Wed, 12 Dec 2012 20:22:08 -0800 (PST)
Date: Wed, 12 Dec 2012 20:24:37 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH 02/11] drivers/base: Add hotplug framework code
Message-ID: <20121213042437.GA14240@kroah.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
 <1355354243-18657-3-git-send-email-toshi.kani@hp.com>
 <20121212235418.GB22764@kroah.com>
 <1355371365.18964.89.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1355371365.18964.89.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: rjw@sisk.pl, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Wed, Dec 12, 2012 at 09:02:45PM -0700, Toshi Kani wrote:
> On Wed, 2012-12-12 at 15:54 -0800, Greg KH wrote:
> > On Wed, Dec 12, 2012 at 04:17:14PM -0700, Toshi Kani wrote:
> > > Added hotplug.c, which is the hotplug framework code.
> > 
> > Again, better naming please.
> 
> Yes, I will change it to be more specific, something like
> "sys_hotplug.c".

Ugh, what's wrong with just a simple "system_bus.c" or something like
that, and then put all of the needed system bus logic in there and tie
the cpus and other sysdev code into that?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
