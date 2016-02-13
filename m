Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 600B26B0009
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 17:23:59 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id c200so65599031wme.0
        for <linux-mm@kvack.org>; Sat, 13 Feb 2016 14:23:59 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id 4si13677859wmb.92.2016.02.13.14.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Feb 2016 14:23:57 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id g62so10849494wme.1
        for <linux-mm@kvack.org>; Sat, 13 Feb 2016 14:23:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <9230470.QhrU67iB7h@wuerfel>
References: <9230470.QhrU67iB7h@wuerfel>
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sat, 13 Feb 2016 17:23:27 -0500
Message-ID: <CAP=VYLpm5ZGq6UrSC_MT4VfvgxB7FYKN37dPQdVBEE_m3YDL_g@mail.gmail.com>
Subject: Re: mm, compaction: fix build errors with kcompactd
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Feb 9, 2016 at 9:15 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> The newly added kcompactd code introduces multiple build errors:
>
> include/linux/compaction.h:91:12: error: 'kcompactd_run' defined but not used [-Werror=unused-function]
> mm/compaction.c:1953:2: error: implicit declaration of function 'hotcpu_notifier' [-Werror=implicit-function-declaration]
>
> This marks the new empty wrapper functions as 'inline' to avoid unused-function warnings,
> and includes linux/cpu.h to get the hotcpu_notifier declaration.
>
> Fixes: 8364acdfa45a ("mm, compaction: introduce kcompactd")

The 8364acdfa45a is a linux-next ID and changes on a daily basis, so you
can't really use a "Fixes" here.  It doesn't matter if akpm just
squishes it into
the original, but I thought I'd mention it for future reference.

P.
..

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> I stumbled over this while trying out the mmots patches today for an unrelated reason.
>
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 1367c0564d42..d7c8de583a23 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -88,15 +88,15 @@ static inline bool compaction_deferred(struct zone *zone, int order)
>         return true;

[...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
