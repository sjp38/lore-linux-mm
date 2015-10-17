Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9F682F64
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 16:33:48 -0400 (EDT)
Received: by padfb7 with SMTP id fb7so8709184pad.2
        for <linux-mm@kvack.org>; Sat, 17 Oct 2015 13:33:48 -0700 (PDT)
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com. [209.85.220.41])
        by mx.google.com with ESMTPS id hq1si39386112pac.161.2015.10.17.13.33.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Oct 2015 13:33:47 -0700 (PDT)
Received: by pasz6 with SMTP id z6so9330926pas.1
        for <linux-mm@kvack.org>; Sat, 17 Oct 2015 13:33:47 -0700 (PDT)
Subject: Re: [PATCH] mm/maccess.c: actually return -EFAULT from
 strncpy_from_unsafe
References: <1445113206-27980-1-git-send-email-linux@rasmusvillemoes.dk>
From: Alexei Starovoitov <ast@plumgrid.com>
Message-ID: <5622B0AC.1050307@plumgrid.com>
Date: Sat, 17 Oct 2015 13:33:48 -0700
MIME-Version: 1.0
In-Reply-To: <1445113206-27980-1-git-send-email-linux@rasmusvillemoes.dk>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Namhyung Kim <namhyung@kernel.org>

On 10/17/15 1:20 PM, Rasmus Villemoes wrote:
> As far as I can tell, strncpy_from_unsafe never returns -EFAULT. ret
> is the result of a __copy_from_user_inatomic(), which is 0 for success
> and positive (in this case necessarily 1) for access error - it is
> never negative. So we were always returning the length of the,
> possibly truncated, destination string.
>
> Signed-off-by: Rasmus Villemoes<linux@rasmusvillemoes.dk>
> ---
> Probably not -stable-worthy. I can only find two callers, one of which
> ignores the return value.

good catch.
Acked-by: Alexei Starovoitov <ast@kernel.org>

cc-ing original authors where I copy pasted that part from.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
