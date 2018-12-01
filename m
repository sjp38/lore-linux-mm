Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08E086B5CF6
	for <linux-mm@kvack.org>; Sat,  1 Dec 2018 03:54:36 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id e17so5982870wrw.13
        for <linux-mm@kvack.org>; Sat, 01 Dec 2018 00:54:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v23sor5272924wrd.4.2018.12.01.00.54.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 01 Dec 2018 00:54:34 -0800 (PST)
Subject: Re: [PATCH] madvise.2: MADV_FREE clarify swapless behavior
References: <20181129181048.11010-1-mhocko@kernel.org>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <79858664-94a8-0b32-f8f0-866c018d7b20@gmail.com>
Date: Sat, 1 Dec 2018 09:54:32 +0100
MIME-Version: 1.0
In-Reply-To: <20181129181048.11010-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: mtk.manpages@gmail.com, linux-mm@kvack.org, =?UTF-8?Q?Niklas_Hamb=c3=bcc?= =?UTF-8?Q?hen?= <mail@nh2.me>, Shaohua Li <shli@fb.com>, linux-man@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On 11/29/18 7:10 PM, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Since 93e06c7a6453 ("mm: enable MADV_FREE for swapless system") we
> handle MADV_FREE on a swapless system the same way as with the swap
> available. Clarify that fact in the man page.

Thanks, Michal (and Niklas). Patch applied.

Cheers,

Michael

> Reported-by: Niklas Hambüchen <mail@nh2.me>
> ---
>  man2/madvise.2 | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/man2/madvise.2 b/man2/madvise.2
> index eb82a57a1cf5..d9135a05a1c2 100644
> --- a/man2/madvise.2
> +++ b/man2/madvise.2
> @@ -403,7 +403,7 @@ The
>  operation
>  can be applied only to private anonymous pages (see
>  .BR mmap (2)).
> -On a swapless system, freeing pages in a given range happens instantly,
> +Prior to 4.12 on a swapless system, freeing pages in a given range happens instantly,
>  regardless of memory pressure.
>  .TP
>  .BR MADV_WIPEONFORK " (since Linux 4.14)"
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
