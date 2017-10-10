Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47C496B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:48:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v2so8654054pfa.4
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:48:50 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00132.outbound.protection.outlook.com. [40.107.0.132])
        by mx.google.com with ESMTPS id 82si8438614pgb.828.2017.10.10.08.48.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 08:48:49 -0700 (PDT)
Subject: Re: [PATCH v3 2/3] Makefile: support flag
 -fsanitizer-coverage=trace-cmp
References: <20171010152731.26031-1-glider@google.com>
 <20171010152731.26031-2-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <6184cd73-6d78-b490-3fdd-2d577ef033a6@virtuozzo.com>
Date: Tue, 10 Oct 2017 18:51:46 +0300
MIME-Version: 1.0
In-Reply-To: <20171010152731.26031-2-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org, mark.rutland@arm.com, alex.popov@linux.com, quentin.casasnovas@oracle.com, dvyukov@google.com, andreyknvl@google.com, keescook@chromium.org, vegard.nossum@oracle.com
Cc: syzkaller@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/10/2017 06:27 PM, Alexander Potapenko wrote:
> 
> v3: - Andrey Ryabinin's comments: reinstated scripts/Makefile.kcov
>       and moved CFLAGS_KCOV there, dropped CFLAGS_KCOV_COMPS

Huh? Try again.

> diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
> index 5e975fee0f5b..7ddd5932c832 100644
> --- a/scripts/Makefile.lib
> +++ b/scripts/Makefile.lib
> @@ -142,6 +142,12 @@ _c_flags += $(if $(patsubst n%,, \
>  	$(CFLAGS_KCOV))
>  endif
>  
> +ifeq ($(CONFIG_KCOV_ENABLE_COMPARISONS),y)
> +_c_flags += $(if $(patsubst n%,, \
> +	$(KCOV_INSTRUMENT_$(basetarget).o)$(KCOV_INSTRUMENT)$(CONFIG_KCOV_INSTRUMENT_ALL)), \
> +	$(CFLAGS_KCOV_COMPS))
> +endif
> +
>  # If building the kernel in a separate objtree expand all occurrences
>  # of -Idir to -I$(srctree)/dir except for absolute paths (starting with '/').
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
