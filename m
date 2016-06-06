Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C79316B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 16:37:09 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f67so99515305ith.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 13:37:09 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-eopbgr30057.outbound.protection.outlook.com. [40.107.3.57])
        by mx.google.com with ESMTPS id t83si9782479oig.89.2016.06.06.13.37.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Jun 2016 13:37:09 -0700 (PDT)
Subject: Re: undefined reference to `early_panic'
References: <201606051227.HWQZ0zJJ%fengguang.wu@intel.com>
 <20160606133120.cb13d4fa3b6bba4f5b427ca5@linux-foundation.org>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <0900b611-cfda-23bc-c56b-7e44a4d56a0d@mellanox.com>
Date: Mon, 6 Jun 2016 16:36:47 -0400
MIME-Version: 1.0
In-Reply-To: <20160606133120.cb13d4fa3b6bba4f5b427ca5@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Linux Memory Management List <linux-mm@kvack.org>

On 6/6/2016 4:31 PM, Andrew Morton wrote:
> On Sun, 5 Jun 2016 12:33:29 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>
>> [...]
>>
>>     arch/tile/built-in.o: In function `setup_arch':
>>>> (.init.text+0x15d8): undefined reference to `early_panic'
>>   
> This?
>
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: tile: early_printk.o is always required
>
> arch/tile/setup.o is always compiled, and it requires early_panic() and
> hence early_printk(), so we must always build and link early_printk.o.
>
> [...]
>
> diff -puN arch/tile/Kconfig~tile-early_printko-is-always-required arch/tile/Kconfig
> --- a/arch/tile/Kconfig~tile-early_printko-is-always-required
> +++ a/arch/tile/Kconfig
> @@ -14,6 +14,7 @@ config TILE
>   	select GENERIC_FIND_FIRST_BIT
>   	select GENERIC_IRQ_PROBE
>   	select GENERIC_IRQ_SHOW
> +	select EARLY_PRINTK
>   	select GENERIC_PENDING_IRQ if SMP
>   	select GENERIC_STRNCPY_FROM_USER
>   	select GENERIC_STRNLEN_USER

Seems plausible; thanks.

Acked-by: Chris Metcalf <cmetcalf@mellanox.com>

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
