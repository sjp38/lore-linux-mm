Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1CB16B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 17:37:37 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z189so56989820itg.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 14:37:37 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id y20si13305594ioy.198.2016.06.07.14.37.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 14:37:37 -0700 (PDT)
Subject: Re: linux-next: Tree for Jun 6 (mm/slub.c)
References: <20160606142058.44b82e38@canb.auug.org.au>
 <57565789.9050508@infradead.org>
 <20160607131242.fac39cbade676df24d70edaa@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <57573E9C.1040604@infradead.org>
Date: Tue, 7 Jun 2016 14:37:32 -0700
MIME-Version: 1.0
In-Reply-To: <20160607131242.fac39cbade676df24d70edaa@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Thomas Garnier <thgarnie@google.com>

On 06/07/16 13:12, Andrew Morton wrote:
> On Mon, 6 Jun 2016 22:11:37 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>> On 06/05/16 21:20, Stephen Rothwell wrote:
>>> Hi all,
>>>
>>> Changes since 20160603:
>>>
>>
>> on i386:
>>
>> mm/built-in.o: In function `init_cache_random_seq':
>> slub.c:(.text+0x76921): undefined reference to `cache_random_seq_create'
>> mm/built-in.o: In function `__kmem_cache_release':
>> (.text+0x80525): undefined reference to `cache_random_seq_destroy'
> 
> Yup.  This, I guess...
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-slub-freelist-randomization-fix
> 
> freelist_randomize(), cache_random_seq_create() and
> cache_random_seq_destroy() should not be inside CONFIG_SLABINFO.
> 
> Cc: Christoph Lameter <cl@linux.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Thomas Garnier <thgarnie@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

Yes, thanks.

Acked-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: Randy Dunlap <rdunlap@infradead.org>

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
