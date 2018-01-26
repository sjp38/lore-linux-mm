Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CCD26B000C
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 14:41:38 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id f3so846349wmc.8
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 11:41:38 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id v79si3526072wrb.43.2018.01.26.11.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jan 2018 11:41:37 -0800 (PST)
Subject: Re: [PATCH 4/6] Protectable Memory
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <c5ae2b4f-4a60-1526-0512-51f1c9a5e4a8@huawei.com>
Date: Fri, 26 Jan 2018 21:41:35 +0200
MIME-Version: 1.0
In-Reply-To: <20180124175631.22925-5-igor.stoppa@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 24/01/18 19:56, Igor Stoppa wrote:

[...]

> +bool pmalloc_prealloc(struct gen_pool *pool, size_t size)
> +{

[...]

> +abort:
> +	vfree(chunk);

this should be vfree_atomic()

[...]

> +void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
> +{

[...]

> +free:
> +	vfree(chunk);

and this one too

I will fix them in the next iteration.
I am waiting to see if any more comments arrive.
Otherwise, I'll send it out probably next Tuesday.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
