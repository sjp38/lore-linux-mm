Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 919BF6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:37:43 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id o11so115581412qge.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:37:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d193si25660578qka.54.2016.01.25.10.37.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 10:37:42 -0800 (PST)
Subject: Re: [PATCH 1/4] arm: Fix wrong bounds check.
References: <1453561543-14756-1-git-send-email-mika.penttila@nextfour.com>
 <1453561543-14756-2-git-send-email-mika.penttila@nextfour.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56A66B74.1060103@redhat.com>
Date: Mon, 25 Jan 2016 10:37:40 -0800
MIME-Version: 1.0
In-Reply-To: <1453561543-14756-2-git-send-email-mika.penttila@nextfour.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mika.penttila@nextfour.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, linux@arm.linux.org.uk

On 01/23/2016 07:05 AM, mika.penttila@nextfour.com wrote:
> From: Mika PenttilA? <mika.penttila@nextfour.com>
>
> Not related to this oops, but while at it, fix incorrect bounds check.
>
> Signed-off-by: Mika PenttilA? mika.penttila@nextfour.com
>
> ---
>   arch/arm/mm/pageattr.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/arm/mm/pageattr.c b/arch/arm/mm/pageattr.c
> index cf30daf..be7fe4b 100644
> --- a/arch/arm/mm/pageattr.c
> +++ b/arch/arm/mm/pageattr.c
> @@ -52,7 +52,7 @@ static int change_memory_common(unsigned long addr, int numpages,
>   	if (start < MODULES_VADDR || start >= MODULES_END)
>   		return -EINVAL;
>
> -	if (end < MODULES_VADDR || start >= MODULES_END)
> +	if (end < MODULES_VADDR || end >= MODULES_END)
>   		return -EINVAL;
>
>   	data.set_mask = set_mask;
>

This has been submitted a few times before, not sure if it is pending
in Russell's patch tracker or nobody has actually submitted it to the
patch tracker.

Russell, is this pending somewhere already?

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
