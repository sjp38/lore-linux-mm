Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36CB56B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 11:18:26 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 3so4004672oix.12
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 08:18:26 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id p8si991924oth.295.2018.02.09.08.18.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 08:18:25 -0800 (PST)
Subject: Re: [PATCH 1/6] genalloc: track beginning of allocations
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204164732.28241-2-igor.stoppa@huawei.com>
 <60e66c5a-c1de-246f-4be8-b02cb0275da6@infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <947ea9c3-b045-17d3-51e5-df80b4fb27e6@huawei.com>
Date: Fri, 9 Feb 2018 18:18:06 +0200
MIME-Version: 1.0
In-Reply-To: <60e66c5a-c1de-246f-4be8-b02cb0275da6@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 05/02/18 00:34, Randy Dunlap wrote:
> On 02/04/2018 08:47 AM, Igor Stoppa wrote:

[...]

> It would be good for a lot of this to be in a source file or the
> pmalloc.rst documentation file instead of living only in the git repository.

This is actually about genalloc. The genalloc documentation is high
level and mostly about the API, while this talks about the guts of the
library. The part modified by the patch. This text doesn't seem to
belong to the generic genalloc documentation.
I will move it to the .c file, but isn't it too much text in a source file?

[...]

>> + * @order: pow of 2 represented by each entry in the bitmap
> 
>               power

ok

[...]

>> + * chunk_size - dimension of a chunk of memory
> 
> can this be more explicit about which dimension?

I'll put "size in bytes of a chunk of memory"


[...]

>> + * cleart_bits_ll - according to the mask, clears the bits specified by
> 
>       clear_bits_ll

yes :-(

[...]

>> - * bitmap_clear_ll - clear the specified number of bits at the specified position
>> + * alter_bitmap_ll - set or clear the entries associated to an allocation
> 
>                                                             with an allocation

ok


>> + * @alteration: selection if the bits selected should be set or cleared
> 
>                    indicates if

ok


[...]

>> +	/* Prepare for writing the initial part of the allocation, from
>> +	 * starting entry, to the end of the UL bitmap element which
>> +	 * contains it. It might be larger than the actual allocation.
>> +	 */
> 
> Use kernel multi-line comment style.

ok, also for further occurrences

[...]

>> +	index =  BITS_DIV_LONGS(start_bit);
> 
> 	index = BITS_DIV_LONGS
> (only 1 space after '=')

oops, yes

--
thank you, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
