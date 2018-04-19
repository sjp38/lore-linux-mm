Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB5696B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:20:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e11so2018932pgv.15
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:20:11 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30112.outbound.protection.outlook.com. [40.107.3.112])
        by mx.google.com with ESMTPS id q21-v6si3954934pls.3.2018.04.19.10.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 10:20:09 -0700 (PDT)
Subject: Re: [PATCH] KASAN: prohibit KASAN+STRUCTLEAK combination
References: <20180419094847.56737-1-dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <d405534b-6d18-715a-85b9-7fc4305d75d3@virtuozzo.com>
Date: Thu, 19 Apr 2018 20:21:02 +0300
MIME-Version: 1.0
In-Reply-To: <20180419094847.56737-1-dvyukov@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, Fengguang Wu <fengguang.wu@intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Kees Cook <keescook@google.com>



On 04/19/2018 12:48 PM, Dmitry Vyukov wrote:

> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -464,6 +464,10 @@ config GCC_PLUGIN_LATENT_ENTROPY
>  config GCC_PLUGIN_STRUCTLEAK
>  	bool "Force initialization of variables containing userspace addresses"
>  	depends on GCC_PLUGINS
> +	# Currently STRUCTLEAK inserts initialization out of live scope of
> +	# variables from KASAN point of view. This leads to KASAN false
> +	# positive reports. Prohibit this combination for now.
> +	depends on !KASAN
                    KASAN_EXTRA
