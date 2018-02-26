Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D77E6B0009
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 07:12:31 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y11so6011641wmd.5
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 04:12:31 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id u13si4322501wmd.165.2018.02.26.04.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 04:12:29 -0800 (PST)
Subject: Re: [PATCH 2/7] genalloc: selftest
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-3-igor.stoppa@huawei.com>
 <76b3d858-b14e-b66d-d8ae-dbd0b307308a@gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <a7b47f45-5929-ae07-1a10-46a02f6db078@huawei.com>
Date: Mon, 26 Feb 2018 14:11:58 +0200
MIME-Version: 1.0
In-Reply-To: <76b3d858-b14e-b66d-d8ae-dbd0b307308a@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J Freyensee <why2jjj.linux@gmail.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 24/02/18 00:42, J Freyensee wrote:
> 
>> +	locations[action->location] = gen_pool_alloc(pool, action->size);
>> +	BUG_ON(!locations[action->location]);
> 
> Again, I'd think it through if you really want to use BUG_ON() or not:
> 
> https://lwn.net/Articles/13183/
> https://lkml.org/lkml/2016/10/4/1

Is it acceptable to display only a WARNing, in case of risking damaging
a mounted filesystem?

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
