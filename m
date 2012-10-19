Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 727E06B005A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 14:27:00 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so899911oag.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 11:26:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350641040-19434-2-git-send-email-wency@cn.fujitsu.com>
References: <1350641040-19434-1-git-send-email-wency@cn.fujitsu.com> <1350641040-19434-2-git-send-email-wency@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 19 Oct 2012 14:26:39 -0400
Message-ID: <CAHGf_=pHQKqL+uSsHbcBe5Jy_NqabUTWFauaPVwN_B6JUn+VBA@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] acpi,memory-hotplug: call acpi_bus_trim() to
 remove memory device
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, liuj97@gmail.com, len.brown@intel.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, muneda.takahiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>

On Fri, Oct 19, 2012 at 6:03 AM,  <wency@cn.fujitsu.com> wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> The memory device has been ejected and powoffed, so we can call
> acpi_bus_trim() to remove the memory device from acpi bus.
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
> ---
>  drivers/acpi/acpi_memhotplug.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index 24c807f..1e90e8f 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -401,8 +401,9 @@ static void acpi_memory_device_notify(acpi_handle handle, u32 event, void *data)
>                 }
>
>                 /*
> -                * TBD: Invoke acpi_bus_remove to cleanup data structures
> +                * Invoke acpi_bus_trim() to remove memory device
>                  */
> +               acpi_bus_trim(device, 1);

I'm happy we removed mysterious acpi_bus_remove().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
