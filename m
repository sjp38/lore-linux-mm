Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 3CE596B0062
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 11:41:25 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so689635vbk.14
        for <linux-mm@kvack.org>; Thu, 09 Aug 2012 08:41:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1343980161-14254-5-git-send-email-wency@cn.fujitsu.com>
References: <1343980161-14254-1-git-send-email-wency@cn.fujitsu.com>
	<1343980161-14254-5-git-send-email-wency@cn.fujitsu.com>
Date: Thu, 9 Aug 2012 17:41:04 +0200
Message-ID: <CAFEPiEY7gBeLoEJggSjFsF92X1Lw9DzPvEfCxhBx75NKCiL6XQ@mail.gmail.com>
Subject: Re: [RFC PATCH V6 04/19] memory-hotplug: offline and remove memory
 when removing the memory device
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

Hi,

> We should offline and remove memory when removing the memory device.
> The memory device can be removed by 2 ways:
> 1. send eject request by SCI
> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
>

[snip]

> +
> +static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
> +{
> +       int result;
> +
> +       /*
> +        * Ask the VM to offline this memory range.
> +        * Note: Assume that this function returns zero on success
> +        */
> +       result = acpi_memory_device_remove_memory(mem_device);
> +

here we should check the result of acpi_memory_device_remove_memory()
and not continue if it failed.

>         /* Power-off and eject the device */
>         result = acpi_memory_powerdown_device(mem_device);
>         if (result) {

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
