Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id D0D106B0253
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:44:59 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id ik10so40732892igb.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:44:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z1si23933igl.72.2016.01.25.10.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 10:44:59 -0800 (PST)
Subject: Re: [PATCH 3/4] arm64: let set_memory_xx(addr, 0) succeed.
References: <1453561543-14756-1-git-send-email-mika.penttila@nextfour.com>
 <1453561543-14756-4-git-send-email-mika.penttila@nextfour.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56A66D28.1080204@redhat.com>
Date: Mon, 25 Jan 2016 10:44:56 -0800
MIME-Version: 1.0
In-Reply-To: <1453561543-14756-4-git-send-email-mika.penttila@nextfour.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mika.penttila@nextfour.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, linux@arm.linux.org.uk, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>

On 01/23/2016 07:05 AM, mika.penttila@nextfour.com wrote:
> From: Mika PenttilA? <mika.penttila@nextfour.com>
>
> This makes set_memory_xx() consistent with x86.
>
> Signed-off-by: Mika PenttilA? mika.penttila@nextfour.com
>
> ---
>   arch/arm64/mm/pageattr.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/arch/arm64/mm/pageattr.c b/arch/arm64/mm/pageattr.c
> index 3571c73..52220dd 100644
> --- a/arch/arm64/mm/pageattr.c
> +++ b/arch/arm64/mm/pageattr.c
> @@ -51,6 +51,9 @@ static int change_memory_common(unsigned long addr, int numpages,
>   		WARN_ON_ONCE(1);
>   	}
>
> +	if (!numpages)
> +		return 0;
> +
>   	if (start < MODULES_VADDR || start >= MODULES_END)
>   		return -EINVAL;
>
>

I think this is going to conflict with Ard's patch
lkml.kernel.org/g/<1453125665-26627-1-git-send-email-ard.biesheuvel@linaro.org>

Can you rebase on top of that?

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
