Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 250706B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 13:29:29 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so28332898pac.13
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 10:29:28 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id ji2si6870769pbb.23.2015.01.28.10.29.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jan 2015 10:29:28 -0800 (PST)
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 3CBB221D91
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 13:29:25 -0500 (EST)
Message-ID: <54C92A82.10805@iki.fi>
Date: Wed, 28 Jan 2015 20:29:22 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
References: <cover.1422461573.git.vdavydov@parallels.com> <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com> <alpine.DEB.2.11.1501281031190.32147@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1501281031190.32147@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/28/15 6:31 PM, Christoph Lameter wrote:
> On Wed, 28 Jan 2015, Vladimir Davydov wrote:
>
>> This patch therefore makes __kmem_cache_shrink() allocate the array on
>> stack instead of calling kmalloc, which may fail. The array size is
>> chosen to be equal to 32, because most SLUB caches store not more than
>> 32 objects per slab page. Slab pages with <= 32 free objects are sorted
>> using the array by the number of objects in use and promoted to the head
>> of the partial list, while slab pages with > 32 free objects are left in
>> the end of the list without any ordering imposed on them.
> Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
