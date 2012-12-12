Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 4D8476B009F
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:55:09 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so1019268pad.14
        for <linux-mm@kvack.org>; Wed, 12 Dec 2012 15:55:08 -0800 (PST)
Date: Wed, 12 Dec 2012 15:55:04 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH 02/11] drivers/base: Add hotplug framework code
Message-ID: <20121212235504.GC22764@kroah.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
 <1355354243-18657-3-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1355354243-18657-3-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: rjw@sisk.pl, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Wed, Dec 12, 2012 at 04:17:14PM -0700, Toshi Kani wrote:
> --- a/drivers/base/Makefile
> +++ b/drivers/base/Makefile
> @@ -21,6 +21,7 @@ endif
>  obj-$(CONFIG_SYS_HYPERVISOR) += hypervisor.o
>  obj-$(CONFIG_REGMAP)	+= regmap/
>  obj-$(CONFIG_SOC_BUS) += soc.o
> +obj-$(CONFIG_HOTPLUG)	+= hotplug.o

CONFIG_HOTPLUG just got always enabled in the kernel, and I'm about to
delete it around the 3.8-rc2 timeframe, so please don't add new usages
of it to the kernel.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
