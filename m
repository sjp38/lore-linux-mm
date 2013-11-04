Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id C3D3A6B0036
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 03:13:27 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so1355531pbb.41
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 00:13:27 -0800 (PST)
Received: from psmtp.com ([74.125.245.106])
        by mx.google.com with SMTP id sw1si9837949pbc.312.2013.11.04.00.13.25
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 00:13:25 -0800 (PST)
Received: by mail-qc0-f176.google.com with SMTP id s19so3817102qcw.35
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 00:13:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1383223953-28803-2-git-send-email-zwu.kernel@gmail.com>
References: <1383223953-28803-1-git-send-email-zwu.kernel@gmail.com>
	<1383223953-28803-2-git-send-email-zwu.kernel@gmail.com>
Date: Mon, 4 Nov 2013 16:13:23 +0800
Message-ID: <CAEH94LjN4ZEFg_UFASpTs4TH+6c_KyMddgoF5Ymk5_1d1EVD3A@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: fix the comment in zlc_setup()
From: Zhi Yong Wu <zwu.kernel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel mlist <linux-kernel@vger.kernel.org>, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>, akpm@linux-foundation.org

CCed Andrew Morton

On Thu, Oct 31, 2013 at 8:52 PM, Zhi Yong Wu <zwu.kernel@gmail.com> wrote:
> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dd886fa..3d94d0c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1711,7 +1711,7 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
>   * comments in mmzone.h.  Reduces cache footprint of zonelist scans
>   * that have to skip over a lot of full or unallowed zones.
>   *
> - * If the zonelist cache is present in the passed in zonelist, then
> + * If the zonelist cache is present in the passed zonelist, then
>   * returns a pointer to the allowed node mask (either the current
>   * tasks mems_allowed, or node_states[N_MEMORY].)
>   *
> --
> 1.7.11.7
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Regards,

Zhi Yong Wu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
