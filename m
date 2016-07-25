Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1598C6B0253
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 14:52:21 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q11so392323965qtb.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 11:52:21 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id n77si5402239ybg.150.2016.07.25.11.52.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 11:52:20 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id q8so15016241qke.3
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 11:52:20 -0700 (PDT)
Date: Mon, 25 Jul 2016 14:52:18 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/memblock.c: fix index adjustment error in
 __next_mem_range_rev()
Message-ID: <20160725185218.GG19588@mtj.duckdns.org>
References: <42A378E55677204FAE257FE7EED241CB7E8EF004@CN-MBX01.HTC.COM.TW>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42A378E55677204FAE257FE7EED241CB7E8EF004@CN-MBX01.HTC.COM.TW>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu@htc.com
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, ard.biesheuvel@linaro.org, tangchen@cn.fujitsu.com, weiyang@linux.vnet.ibm.com, dev@g0hl1n.net, david@gibson.dropbear.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 25, 2016 at 07:34:12AM +0000, zijun_hu@htc.com wrote:
> Hi All,
>          There is a bug in mm/memblock.c
>          Could you review and phase-in this patch?
>          Thanks a lot
> 
> From 3abf1822d30f77f126bd7a3c09bb243d9c17a029 Mon Sep 17 00:00:00 2001
> From: zijun_hu <zijun_hu@htc.com>
> Date: Mon, 25 Jul 2016 15:06:57 +0800
> Subject: [PATCH] mm/memblock.c: fix index adjustment error in
> __next_mem_range_rev()
> 
> fix region index adjustment error when parameter type_b of
> __next_mem_range_rev() == NULL
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> ---
> mm/memblock.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index ac12489..b14973e 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1024,7 +1024,7 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
>                                  *out_end = m_end;
>                         if (out_nid)
>                                  *out_nid = m_nid;
> -                         idx_a++;
> +                        idx_a--;

Looks good to me.  Do you happen to have a test case for this bug?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
