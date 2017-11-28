Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8226B0069
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 14:41:11 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g1so471425pgo.14
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 11:41:11 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f20si8378558pgv.712.2017.11.28.11.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 11:41:09 -0800 (PST)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 02/18] vchecker: introduce the valid access checker
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1511855333-3570-3-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 28 Nov 2017 11:41:08 -0800
In-Reply-To: <1511855333-3570-3-git-send-email-iamjoonsoo.kim@lge.com> (js's
	message of "Tue, 28 Nov 2017 16:48:37 +0900")
Message-ID: <87k1yajinf.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

js1304@gmail.com writes:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Looks useful. Essentially unlimited hardware break points, combined
with slab.

Didn't do a full review, but noticed some things below.
> +
> +	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	if (copy_from_user(buf, ubuf, cnt)) {
> +		kfree(buf);
> +		return -EFAULT;
> +	}
> +
> +	if (isspace(buf[0]))
> +		remove = true;

and that may be uninitialized.

and the space changes the operation? That's a strange syntax.


> +	buf[cnt - 1] = '\0';

That's an underflow of one byte if cnt is 0.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
