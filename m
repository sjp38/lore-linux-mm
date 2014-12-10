Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 555D96B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 01:55:02 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so10201305wiw.14
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 22:55:01 -0800 (PST)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com. [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id bc9si5894107wjb.90.2014.12.09.22.55.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 22:55:01 -0800 (PST)
Received: by mail-wg0-f46.google.com with SMTP id x13so2778268wgg.5
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 22:55:01 -0800 (PST)
Date: Wed, 10 Dec 2014 07:54:57 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH V3 2/2] x86/mm: use min instead of min_t
Message-ID: <20141210065457.GA20596@gmail.com>
References: <5487AB3F.7050807@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5487AB3F.7050807@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, dave@sr71.net, Rik van Riel <riel@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>


* Xishi Qiu <qiuxishi@huawei.com> wrote:

> The type of "MAX_DMA_PFN" and "xXx_pfn" are both unsigned long now, so use
> min() instead of min_t().
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>  arch/x86/kernel/e820.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> index 49f8864..dd2f07a 100644
> --- a/arch/x86/kernel/e820.c
> +++ b/arch/x86/kernel/e820.c
> @@ -1114,8 +1114,8 @@ void __init memblock_find_dma_reserve(void)
>  	 * at first, and assume boot_mem will not take below MAX_DMA_PFN
>  	 */
>  	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, NULL) {
> -		start_pfn = min_t(unsigned long, start_pfn, MAX_DMA_PFN);
> -		end_pfn = min_t(unsigned long, end_pfn, MAX_DMA_PFN);
> +		start_pfn = min(start_pfn, MAX_DMA_PFN);
> +		end_pfn = min(end_pfn, MAX_DMA_PFN);
>  		nr_pages += end_pfn - start_pfn;

Yes, harmonizing the types is a much nicer solution, it allows 
cleanups like this.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
