Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3000A6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 15:34:33 -0500 (EST)
Received: by igal13 with SMTP id l13so19215442iga.1
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:34:33 -0800 (PST)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id h9si5817067iod.13.2015.03.02.12.34.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 12:34:32 -0800 (PST)
Received: by igal13 with SMTP id l13so20769358iga.5
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:34:32 -0800 (PST)
Date: Mon, 2 Mar 2015 12:34:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/4] mm: Clarify __GFP_NOFAIL deprecation status
In-Reply-To: <1425304483-7987-2-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.DEB.2.10.1503021233550.20808@chino.kir.corp.google.com>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz> <1425304483-7987-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Vipul Pandya <vipul@chelsio.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 2 Mar 2015, Michal Hocko wrote:

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 51bd1e72a917..0cf9c2772988 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -57,8 +57,10 @@ struct vm_area_struct;
>   * _might_ fail.  This depends upon the particular VM implementation.
>   *
>   * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
> - * cannot handle allocation failures.  This modifier is deprecated and no new
> - * users should be added.
> + * cannot handle allocation failures. New users should be evaluated carefuly
> + * (and the flag should be used only when there is no reasonable failure policy)
> + * but it is definitely preferable to use the flag rather than opencode endless
> + * loop around allocator.
>   *
>   * __GFP_NORETRY: The VM implementation must not retry indefinitely.
>   *

s/carefuly/carefully/

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
