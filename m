Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE1D6B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 20:43:05 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id u126so4090166oif.23
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 17:43:05 -0800 (PST)
Received: from mail5.wrs.com (mail5.windriver.com. [192.103.53.11])
        by mx.google.com with ESMTPS id s131si1994416oif.355.2017.12.07.17.43.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 17:43:04 -0800 (PST)
Subject: Re: [PATCH 8/8] net: tipc: remove unused hardirq.h
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
 <1510959741-31109-8-git-send-email-yang.s@alibaba-inc.com>
From: Ying Xue <ying.xue@windriver.com>
Message-ID: <4ed1efbc-5fb8-7412-4f46-1e3a91a98373@windriver.com>
Date: Fri, 8 Dec 2017 09:40:30 +0800
MIME-Version: 1.0
In-Reply-To: <1510959741-31109-8-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>, "David S. Miller" <davem@davemloft.net>

On 11/18/2017 07:02 AM, Yang Shi wrote:
> Preempt counter APIs have been split out, currently, hardirq.h just
> includes irq_enter/exit APIs which are not used by TIPC at all.
> 
> So, remove the unused hardirq.h.
> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> Cc: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Ying Xue <ying.xue@windriver.com>
> Cc: "David S. Miller" <davem@davemloft.net>

Tested-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/core.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/tipc/core.h b/net/tipc/core.h
> index 5cc5398..099e072 100644
> --- a/net/tipc/core.h
> +++ b/net/tipc/core.h
> @@ -49,7 +49,6 @@
>  #include <linux/uaccess.h>
>  #include <linux/interrupt.h>
>  #include <linux/atomic.h>
> -#include <asm/hardirq.h>
>  #include <linux/netdevice.h>
>  #include <linux/in.h>
>  #include <linux/list.h>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
