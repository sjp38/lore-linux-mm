Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 253836B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:47:50 -0500 (EST)
Received: by mail-lf0-f48.google.com with SMTP id j78so56894292lfb.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:47:50 -0800 (PST)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com. [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id n184si6022727lfb.169.2016.02.26.08.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 08:47:48 -0800 (PST)
Received: by mail-lb0-x236.google.com with SMTP id ep2so17862575lbb.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:47:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456461361-4345-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456461361-4345-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Fri, 26 Feb 2016 19:47:48 +0300
Message-ID: <CAPAsAGytHfMaX8VzgWX-PBXcH8aO0G82L3ZX5dSNa=trBFVsyg@mail.gmail.com>
Subject: Re: [PATCH v2] mm/slub: support left redzone
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-26 7:36 GMT+03:00  <js1304@gmail.com>:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> SLUB already has a redzone debugging feature.  But it is only positioned
> at the end of object (aka right redzone) so it cannot catch left oob.
> Although current object's right redzone acts as left redzone of next
> object, first object in a slab cannot take advantage of this effect.  This
> patch explicitly adds a left red zone to each object to detect left oob
> more precisely.
>

So why for each object? Can't we have left redzone only for the first object?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
