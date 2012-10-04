Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 058786B00ED
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 22:41:17 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm1so6365bkc.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2012 19:41:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506CEADA.9060108@jp.fujitsu.com>
References: <506CE9F5.8020809@jp.fujitsu.com>
	<506CEADA.9060108@jp.fujitsu.com>
Date: Wed, 3 Oct 2012 19:41:16 -0700
Message-ID: <CAE9FiQWaESFEBp+7w+E-ZfjgG4YFSTREoKfjNWNiOyhntf=uzg@mail.gmail.com>
Subject: Re: [PATCH 2/2] acpi,memory-hotplug : call acpi_bus_remo() to remove
 memory device
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, len.brown@intel.com, wency@cn.fujitsu.com

On Wed, Oct 3, 2012 at 6:48 PM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> The memory device has been ejected and powoffed, so we can call
> acpi_bus_remove() to remove the memory device from acpi bus.
>
> CC: Len Brown <len.brown@intel.com>
> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> ---
>  drivers/acpi/acpi_memhotplug.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> Index: linux-3.6/drivers/acpi/acpi_memhotplug.c
> ===================================================================
> --- linux-3.6.orig/drivers/acpi/acpi_memhotplug.c       2012-10-03 18:17:47.802249170 +0900
> +++ linux-3.6/drivers/acpi/acpi_memhotplug.c    2012-10-03 18:17:52.471250299 +0900
> @@ -424,8 +424,9 @@ static void acpi_memory_device_notify(ac
>                 }
>
>                 /*
> -                * TBD: Invoke acpi_bus_remove to cleanup data structures
> +                * Invoke acpi_bus_remove() to remove memory device
>                  */
> +               acpi_bus_remove(device, 1);

why not using acpi_bus_trim instead?

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
