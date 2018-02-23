Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A18996B0005
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 17:43:02 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f4so4469778plo.11
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 14:43:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6-v6sor1151758pla.107.2018.02.23.14.43.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 14:43:01 -0800 (PST)
Subject: Re: [PATCH 2/7] genalloc: selftest
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-3-igor.stoppa@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <76b3d858-b14e-b66d-d8ae-dbd0b307308a@gmail.com>
Date: Fri, 23 Feb 2018 14:42:57 -0800
MIME-Version: 1.0
In-Reply-To: <20180223144807.1180-3-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com


> +	locations[action->location] = gen_pool_alloc(pool, action->size);
> +	BUG_ON(!locations[action->location]);

Again, I'd think it through if you really want to use BUG_ON() or not:

https://lwn.net/Articles/13183/
https://lkml.org/lkml/2016/10/4/1

Thanks,
Jay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
