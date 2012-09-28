Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 875946B005D
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 23:21:49 -0400 (EDT)
Received: by obcva7 with SMTP id va7so3141774obc.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 20:21:48 -0700 (PDT)
Message-ID: <506517C1.7050909@gmail.com>
Date: Fri, 28 Sep 2012 11:21:37 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v9 PATCH 03/21] memory-hotplug: store the node id in acpi_memory_device
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com> <1346837155-534-4-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346837155-534-4-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

On 09/05/2012 05:25 PM, wency@cn.fujitsu.com wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> The memory device has only one node id. Store the node id when
> enable the memory device, and we can reuse it when removing the
> memory device.

one question:
if use numa emulation, memory device will associated to one node or ...?

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
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>   drivers/acpi/acpi_memhotplug.c |    4 ++++
>   1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index 2a7beac..7873832 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -83,6 +83,7 @@ struct acpi_memory_info {
>   struct acpi_memory_device {
>   	struct acpi_device * device;
>   	unsigned int state;	/* State of the memory device */
> +	int nid;
>   	struct list_head res_list;
>   };
>   
> @@ -256,6 +257,9 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>   		info->enabled = 1;
>   		num_enabled++;
>   	}
> +
> +	mem_device->nid = node;
> +
>   	if (!num_enabled) {
>   		printk(KERN_ERR PREFIX "add_memory failed\n");
>   		mem_device->state = MEMORY_INVALID_STATE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
