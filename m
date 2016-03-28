Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 038E56B0263
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 02:05:20 -0400 (EDT)
Received: by mail-oi0-f50.google.com with SMTP id o62so46322855oig.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 23:05:19 -0700 (PDT)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id v2si3749407oib.1.2016.03.27.23.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 23:05:19 -0700 (PDT)
Received: by mail-oi0-x229.google.com with SMTP id o62so46322665oig.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 23:05:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1459144748-13664-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459144748-13664-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1459144748-13664-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 28 Mar 2016 15:05:19 +0900
Message-ID: <CAAmzW4PjMfoQR3OJPX8Xp1DcBqzSQx4JE0M239EOH-Gvz0qQ-Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: rename _count, field of the struct page, to _refcount
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Berg <johannes@sipsolutions.net>, "David S. Miller" <davem@davemloft.net>, Sunil Goutham <sgoutham@cavium.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-03-28 14:59 GMT+09:00  <js1304@gmail.com>:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Many developer already know that field for reference count of
> the struct page is _count and atomic type. They would try to handle it
> directly and this could break the purpose of page reference count
> tracepoint. To prevent direct _count modification, this patch rename it
> to _refcount and add warning message on the code. After that, developer
> who need to handle reference count will find that field should not be
> accessed directly.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Oops. This patch needs more change. Please ignore this patchset.
I will resend it soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
