Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9D86B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:21:36 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id zv1so43782820obb.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:21:36 -0800 (PST)
Received: from mail-ob0-x244.google.com (mail-ob0-x244.google.com. [2607:f8b0:4003:c01::244])
        by mx.google.com with ESMTPS id gu9si22922312obc.36.2016.01.26.07.21.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 07:21:35 -0800 (PST)
Received: by mail-ob0-x244.google.com with SMTP id oj9so11761125obc.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:21:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601260900370.27338@east.gentwo.org>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
	<20160126070320.GB28254@js1304-P5Q-DELUXE>
	<alpine.DEB.2.20.1601260900370.27338@east.gentwo.org>
Date: Wed, 27 Jan 2016 00:21:35 +0900
Message-ID: <CAAmzW4P+s+z0p=43SfdrPS=+2iuKqvQKZdAwc=zUENuDS0RvxQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/3] Speed up SLUB poisoning + disable checks
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@fedoraproject.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

2016-01-27 0:01 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Tue, 26 Jan 2016, Joonsoo Kim wrote:
>
>> I doesn't follow up that discussion, but, I think that reusing
>> SLAB_POISON for slab sanitization needs more changes. I assume that
>> completeness and performance is matter for slab sanitization.
>>
>> 1) SLAB_POISON isn't applied to specific kmem_cache which has
>> constructor or SLAB_DESTROY_BY_RCU flag. For debug, it's not necessary
>> to be applied, but, for slab sanitization, it is better to apply it to
>> all caches.
>
> Those slabs can be legitimately accessed after the objects were freed. You
> cannot sanitize nor poison.

Oops... you are right. I misunderstand what SLAB_DESTROY_BY_RCU is.
Now, it's clear to me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
