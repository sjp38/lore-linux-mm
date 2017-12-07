Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3B26B0273
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:16:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w1so5844149pgq.21
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:16:12 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTPS id s3si606814plq.832.2017.12.07.11.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 11:16:11 -0800 (PST)
Subject: Re: [PATCH 8/8] net: tipc: remove unused hardirq.h
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
 <1510959741-31109-8-git-send-email-yang.s@alibaba-inc.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <da42d136-4e51-6d04-4120-cb53df03c661@alibaba-inc.com>
Date: Fri, 08 Dec 2017 03:15:50 +0800
MIME-Version: 1.0
In-Reply-To: <1510959741-31109-8-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>, Ying Xue <ying.xue@windriver.com>, "David S. Miller" <davem@davemloft.net>

Hi folks,

Any comment on this one?

Thanks,
Yang


On 11/17/17 3:02 PM, Yang Shi wrote:
> Preempt counter APIs have been split out, currently, hardirq.h just
> includes irq_enter/exit APIs which are not used by TIPC at all.
> 
> So, remove the unused hardirq.h.
> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> Cc: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Ying Xue <ying.xue@windriver.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> ---
>   net/tipc/core.h | 1 -
>   1 file changed, 1 deletion(-)
> 
> diff --git a/net/tipc/core.h b/net/tipc/core.h
> index 5cc5398..099e072 100644
> --- a/net/tipc/core.h
> +++ b/net/tipc/core.h
> @@ -49,7 +49,6 @@
>   #include <linux/uaccess.h>
>   #include <linux/interrupt.h>
>   #include <linux/atomic.h>
> -#include <asm/hardirq.h>
>   #include <linux/netdevice.h>
>   #include <linux/in.h>
>   #include <linux/list.h>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
