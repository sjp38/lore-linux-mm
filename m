Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D3FC06B0035
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 03:20:13 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2312740pab.32
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 00:20:13 -0700 (PDT)
Message-ID: <525F8FA4.3000702@iki.fi>
Date: Thu, 17 Oct 2013 09:20:04 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/15] slab: overload struct slab over struct page
 to reduce memory usage
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <20131016133457.60fa71f893cd2962d8ec6ff3@linux-foundation.org>
In-Reply-To: <20131016133457.60fa71f893cd2962d8ec6ff3@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 10/16/13 10:34 PM, Andrew Morton wrote:
> On Wed, 16 Oct 2013 17:43:57 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>
>> There is two main topics in this patchset. One is to reduce memory usage
>> and the other is to change a management method of free objects of a slab.
>>
>> The SLAB allocate a struct slab for each slab. The size of this structure
>> except bufctl array is 40 bytes on 64 bits machine. We can reduce memory
>> waste and cache footprint if we overload struct slab over struct page.
> Seems a good idea from a quick look.

Indeed.

Christoph, I'd like to pick this up and queue for linux-next. Any
objections or comments to the patches?

                     Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
