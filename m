Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C8A7D6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 02:45:06 -0400 (EDT)
Received: by payr10 with SMTP id r10so7513567pay.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 23:45:06 -0700 (PDT)
Received: from mgwkm02.jp.fujitsu.com (mgwkm02.jp.fujitsu.com. [202.219.69.169])
        by mx.google.com with ESMTPS id fk8si7555610pab.89.2015.06.08.23.45.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 23:45:06 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 3BB51AC0388
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 15:45:02 +0900 (JST)
Message-ID: <55768B42.80503@jp.fujitsu.com>
Date: Tue, 09 Jun 2015 15:44:18 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 01/12] mm: add a new config to manage the code
References: <55704A7E.5030507@huawei.com> <55704B0C.1000308@huawei.com>
In-Reply-To: <55704B0C.1000308@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/04 21:56, Xishi Qiu wrote:
> This patch introduces a new config called "CONFIG_ACPI_MIRROR_MEMORY", it is
> used to on/off the feature.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>   mm/Kconfig | 8 ++++++++
>   1 file changed, 8 insertions(+)
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 390214d..4f2a726 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -200,6 +200,14 @@ config MEMORY_HOTREMOVE
>   	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>   	depends on MIGRATION
>
> +config MEMORY_MIRROR
> +	bool "Address range mirroring support"
> +	depends on X86 && NUMA
> +	default y
> +	help
> +	  This feature depends on hardware and firmware support.
> +	  ACPI or EFI records the mirror info.

default y...no runtime influence when the user doesn't use memory mirror ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
