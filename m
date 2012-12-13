Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id CC41F6B002B
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 23:07:38 -0500 (EST)
Message-ID: <1355371116.18964.85.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH 02/11] drivers/base: Add hotplug framework code
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 12 Dec 2012 20:58:36 -0700
In-Reply-To: <20121212235504.GC22764@kroah.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
	 <1355354243-18657-3-git-send-email-toshi.kani@hp.com>
	 <20121212235504.GC22764@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: rjw@sisk.pl, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Wed, 2012-12-12 at 15:55 -0800, Greg KH wrote:
> On Wed, Dec 12, 2012 at 04:17:14PM -0700, Toshi Kani wrote:
> > --- a/drivers/base/Makefile
> > +++ b/drivers/base/Makefile
> > @@ -21,6 +21,7 @@ endif
> >  obj-$(CONFIG_SYS_HYPERVISOR) += hypervisor.o
> >  obj-$(CONFIG_REGMAP)	+= regmap/
> >  obj-$(CONFIG_SOC_BUS) += soc.o
> > +obj-$(CONFIG_HOTPLUG)	+= hotplug.o
> 
> CONFIG_HOTPLUG just got always enabled in the kernel, and I'm about to
> delete it around the 3.8-rc2 timeframe, so please don't add new usages
> of it to the kernel.

Sounds good.  I will simply change it obj-y then.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
