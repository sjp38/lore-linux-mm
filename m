Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 648396B0078
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:17:43 -0500 (EST)
Message-ID: <1353017366.12509.19.camel@misato.fc.hp.com>
Subject: Re: [Patch v5 2/7] acpi,memory-hotplug: deal with eject request in
 hotplug queue
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 15 Nov 2012 15:09:26 -0700
In-Reply-To: <1352962777-24407-3-git-send-email-wency@cn.fujitsu.com>
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com>
	 <1352962777-24407-3-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, "Rafael J.
 Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

On Thu, 2012-11-15 at 14:59 +0800, Wen Congyang wrote:
> The memory device can be removed by 2 ways:
> 1. send eject request by SCI
> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> 
> We handle the 1st case in the module acpi_memhotplug, and handle
> the 2nd case in ACPI eject notification. This 2 events may happen
> at the same time, so we may touch acpi_memory_device.res_list at
> the same time. This patch reimplements memory-hotremove support
> through an ACPI eject notification. Now the memory device is
> offlined and hotremoved only in the function acpi_memory_device_remove()
> which is protected by device_lock().
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
> CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> CC: Rafael J. Wysocki <rjw@sisk.pl>
> CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>

Thanks for the update.  It looks good.

Reviewed-by: Toshi Kani <toshi.kani@hp.com>

-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
