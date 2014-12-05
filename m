Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2B66B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 03:32:54 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so272411wgh.12
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 00:32:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cf4si1460273wib.11.2014.12.05.00.32.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 00:32:52 -0800 (PST)
Date: Fri, 5 Dec 2014 09:32:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20141205083249.GA2321@dhcp22.suse.cz>
References: <1413799924-17946-1-git-send-email-minchan@kernel.org>
 <1413799924-17946-2-git-send-email-minchan@kernel.org>
 <20141127144725.GB19157@dhcp22.suse.cz>
 <20141130235652.GA10333@bbox>
 <20141202100125.GD27014@dhcp22.suse.cz>
 <20141203000026.GA30217@bbox>
 <20141203101329.GB23236@dhcp22.suse.cz>
 <20141205070816.GB3358@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141205070816.GB3358@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri 05-12-14 16:08:16, Minchan Kim wrote:
[...]
> From cfa212d4fb307ae772b08cf564cab7e6adb8f4fc Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Mon, 1 Dec 2014 08:53:55 +0900
> Subject: [PATCH] madvise.2: Document MADV_FREE
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  man2/madvise.2 | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/man2/madvise.2 b/man2/madvise.2
> index 032ead7..fc1aaca 100644
> --- a/man2/madvise.2
> +++ b/man2/madvise.2
> @@ -265,6 +265,18 @@ file (see
>  .BR MADV_DODUMP " (since Linux 3.4)"
>  Undo the effect of an earlier
>  .BR MADV_DONTDUMP .
> +.TP
> +.BR MADV_FREE " (since Linux 3.19)"
> +Tell the kernel that contents in the specified address range are no
> +longer important and the range will be overwritten. When there is
> +demand for memory, the system will free pages associated with the
> +specified address range. In this instance, the next time a page in the
> +address range is referenced, it will contain all zeroes.  Otherwise,
> +it will contain the data that was there prior to the MADV_FREE call.
> +References made to the address range will not make the system read
> +from backing store (swap space) until the page is modified again.
> +It works only with private anonymous pages (see
> +.BR mmap (2)).
>  .SH RETURN VALUE
>  On success
>  .BR madvise ()
> -- 
> 2.0.0
> 
> -- 
> Kind regards,
> Minchan Kim
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
