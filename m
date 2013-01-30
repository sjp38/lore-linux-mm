Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id F249F6B000C
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 03:09:34 -0500 (EST)
Date: Tue, 29 Jan 2013 23:54:37 -0500
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v2 03/12] drivers/base: Add system device hotplug
 framework
Message-ID: <20130130045437.GG30002@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
 <1357861230-29549-4-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357861230-29549-4-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: rjw@sisk.pl, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Thu, Jan 10, 2013 at 04:40:21PM -0700, Toshi Kani wrote:
> Added sys_hotplug.c, which is the system device hotplug framework code.
> 
> shp_register_handler() allows modules to register their hotplug handlers
> to the framework.  shp_submit_req() provides the interface to submit
> a hotplug or online/offline request of system devices.  The request is
> then put into hp_workqueue.  shp_start_req() calls all registered handlers
> in ascending order for each phase.  If any handler failed in validate or
> execute phase, shp_start_req() initiates its rollback procedure.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  drivers/base/Makefile      |    1 
>  drivers/base/sys_hotplug.c |  313 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 314 insertions(+)
>  create mode 100644 drivers/base/sys_hotplug.c
> 
> diff --git a/drivers/base/Makefile b/drivers/base/Makefile
> index 5aa2d70..2e9b2f1 100644
> --- a/drivers/base/Makefile
> +++ b/drivers/base/Makefile
> @@ -21,6 +21,7 @@ endif
>  obj-$(CONFIG_SYS_HYPERVISOR) += hypervisor.o
>  obj-$(CONFIG_REGMAP)	+= regmap/
>  obj-$(CONFIG_SOC_BUS) += soc.o
> +obj-y			+= sys_hotplug.o

No option to select this for systems that don't need it?  If not, then
put it up higher with all of the other code for the core.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
