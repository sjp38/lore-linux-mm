Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id CEF1D6B004D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:03:14 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1556478pad.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 15:03:14 -0800 (PST)
Date: Thu, 15 Nov 2012 15:03:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Patch v5 1/7] acpi,memory-hotplug : add memory offline code to
 acpi_memory_device_remove()
In-Reply-To: <1352962777-24407-2-git-send-email-wency@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1211151501180.27188@chino.kir.corp.google.com>
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com> <1352962777-24407-2-git-send-email-wency@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

On Thu, 15 Nov 2012, Wen Congyang wrote:

> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> The memory device can be removed by 2 ways:
> 1. send eject request by SCI
> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> 
> In the 1st case, acpi_memory_disable_device() will be called.
> In the 2nd case, acpi_memory_device_remove() will be called.
> acpi_memory_device_remove() will also be called when we unbind the
> memory device from the driver acpi_memhotplug or a driver initialization
> fails.
> 
> acpi_memory_disable_device() has already implemented a code which
> offlines memory and releases acpi_memory_info struct. But
> acpi_memory_device_remove() has not implemented it yet.
> 
> So the patch move offlining memory and releasing acpi_memory_info struct
> codes to a new function acpi_memory_remove_memory(). And it is used by both
> acpi_memory_device_remove() and acpi_memory_disable_device().
> 
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Rafael J. Wysocki <rjw@sisk.pl>
> CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
