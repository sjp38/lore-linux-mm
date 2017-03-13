Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 978636B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 10:24:02 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id p41so226981272otb.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:24:02 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0116.outbound.protection.outlook.com. [104.47.0.116])
        by mx.google.com with ESMTPS id q9si4628859ota.293.2017.03.13.07.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 07:24:01 -0700 (PDT)
Subject: Re: [mm/kasan] 80a9201a59 BUG: kernel reboot-without-warning in
 early-boot stage, last printk: Booting the kernel.
References: <20170228031227.tm7flsxl7t7klspf@wfg-t540p.sh.intel.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5211ff97-29ab-c3b5-670b-db98662ce009@virtuozzo.com>
Date: Mon, 13 Mar 2017 17:25:04 +0300
MIME-Version: 1.0
In-Reply-To: <20170228031227.tm7flsxl7t7klspf@wfg-t540p.sh.intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, LKP <lkp@01.org>, Dmitry Vyukov <dvyukov@google.com>

On 02/28/2017 06:12 AM, Fengguang Wu wrote:
> Hi Alexander,
> 
> FYI, we find an old bug that's still alive in linux-next. The attached
> reproduce-* script may help debug the problem.
> 

...

> +--------------------------------------------------------------------------------------+------------+------------+
> |                                                                                      | c146a2b98e | 80a9201a59 |
> +--------------------------------------------------------------------------------------+------------+------------+
> | boot_successes                                                                       | 740        | 48         |
> | boot_failures                                                                        | 0          | 142        |
> | BUG:kernel_reboot-without-warning_in_early-boot_stage,last_printk:Booting_the_kernel | 0          | 131        |
> | BUG:kernel_in_stage                                                                  | 0          | 11         |
> +--------------------------------------------------------------------------------------+------------+------------+
> 


Indeed it is an old bug, I'll send a fix shortly. But the bisection result is not correct. This bug is actually much older.
Note that commit 80a9201a596 changes Kconfig dependency - it removes depends on SLUB_DEBUG from config KASAN section.
And yours config has:
	# CONFIG_SLUB_DEBUG is not set

So you simply test c146a2b98e with CONFIG_KASAN=n and 80a9201a59 with CONFIG_KASAN=y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
