Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2831A900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:13:23 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so252225000pac.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 14:13:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bu7si4562420pad.116.2015.04.21.14.13.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Apr 2015 14:13:22 -0700 (PDT)
Date: Tue, 21 Apr 2015 14:13:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, hwpoison: Add comment describing when to add new
 cases
Message-Id: <20150421141320.3ecb24f7679c2e874f9c056c@linux-foundation.org>
In-Reply-To: <1429639890-14116-1-git-send-email-andi@firstfloor.org>
References: <1429639890-14116-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Tue, 21 Apr 2015 11:11:30 -0700 Andi Kleen <andi@firstfloor.org> wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> Here's another comment fix for hwpoison.
> 
> It describes the "guiding principle" on when to add new
> memory error recovery code.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  mm/memory-failure.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 25c2054..d553993 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -20,6 +20,13 @@
>   * this code has to be extremely careful. Generally it tries to use 
>   * normal locking rules, as in get the standard locks, even if that means 
>   * the error handling takes potentially a long time.
> + *
> + * It can be very tempting to add handling for obscure cases here.
> + * In general any code for handling new cases should only be added if:
> + * - You know how to test it.
> + * - You have a test that can be added to mce-test

Some additional details on mce-test might be useful.  The goog leads me
to https://github.com/andikleen/mce-test but that hasn't been touched
in 3 years?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
