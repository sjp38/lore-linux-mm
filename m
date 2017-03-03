Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B48216B0396
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 08:20:02 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id y136so34434612iof.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 05:20:02 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20109.outbound.protection.outlook.com. [40.107.2.109])
        by mx.google.com with ESMTPS id p69si2312168ita.56.2017.03.03.05.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 05:20:01 -0800 (PST)
Subject: Re: [PATCH v2 5/9] kasan: change report header
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-6-andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <028eee50-f14f-034d-6e8a-9d07276543b5@virtuozzo.com>
Date: Fri, 3 Mar 2017 16:21:07 +0300
MIME-Version: 1.0
In-Reply-To: <20170302134851.101218-6-andreyknvl@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 03/02/2017 04:48 PM, Andrey Konovalov wrote:

> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 8b0b27eb37cd..945d0e13e8a4 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -130,11 +130,11 @@ static void print_error_description(struct kasan_access_info *info)
>  {
>  	const char *bug_type = get_bug_type(info);
>  
> -	pr_err("BUG: KASAN: %s in %pS at addr %p\n",
> -		bug_type, (void *)info->ip, info->access_addr);
> -	pr_err("%s of size %zu by task %s/%d\n",
> +	pr_err("BUG: KASAN: %s in %pS\n",
> +		bug_type, (void *)info->ip);

This should fit in one line without exceeding 80-char limit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
