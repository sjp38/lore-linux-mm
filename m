Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61A2B6B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 07:07:13 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id e79so37771812ioi.6
        for <linux-mm@kvack.org>; Mon, 29 May 2017 04:07:13 -0700 (PDT)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id 127si8981486ion.129.2017.05.29.04.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 04:07:12 -0700 (PDT)
Received: by mail-io0-x241.google.com with SMTP id 12so6578422iol.1
        for <linux-mm@kvack.org>; Mon, 29 May 2017 04:07:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <7f85724c-6fc1-bb51-11e4-15fc2f89372b@linux.vnet.ibm.com>
References: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
 <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
 <20170523070227.GA27864@infradead.org> <09a6bafa-5743-425e-8def-bd9219cd756c@suse.cz>
 <161638da-3b2b-7912-2ae2-3b2936ca1537@linux.vnet.ibm.com> <7f85724c-6fc1-bb51-11e4-15fc2f89372b@linux.vnet.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 29 May 2017 13:07:10 +0200
Message-ID: <CAMuHMdVHyd8LV4_LhFLqHBr0qOUZCKY973edWs5jzv5U6qcgOw@mail.gmail.com>
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Anshuman,

On Wed, May 24, 2017 at 8:40 AM, Anshuman Khandual
<khandual@linux.vnet.ibm.com> wrote:
> On 05/23/2017 04:49 PM, Anshuman Khandual wrote:
>> On 05/23/2017 02:08 PM, Vlastimil Babka wrote:
>>> On 05/23/2017 09:02 AM, Christoph Hellwig wrote:
>>>> On Mon, May 22, 2017 at 02:11:49PM -0700, Andrew Morton wrote:
>>>>> On Mon, 22 May 2017 16:47:42 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:
>>>>>> There are many places where we define size either left shifting integers
>>>>>> or multiplying 1024s without any generic definition to fall back on. But
>>>>>> there are couples of (powerpc and lz4) attempts to define these standard
>>>>>> memory sizes. Lets move these definitions to core VM to make sure that
>>>>>> all new usage come from these definitions eventually standardizing it
>>>>>> across all places.
>>>>> Grep further - there are many more definitions and some may now
>>>>> generate warnings.
>>>>>
>>>>> Newly including mm.h for these things seems a bit heavyweight.  I can't
>>>>> immediately think of a more appropriate place.  Maybe printk.h or
>>>>> kernel.h.
>>>> IFF we do these kernel.h is the right place.  And please also add the
>>>> MiB & co variants for the binary versions right next to the decimal
>>>> ones.
>>> Those defined in the patch are binary, not decimal. Do we even need
>>> decimal ones?
>>
>> I can define KiB, MiB, .... with the same values as binary.
>> Did not get about the decimal ones, we need different names
>> for them holding values which are multiple of 1024 ?
>
> Now it seems little bit complicated than I initially thought.
> There are three different kind of definitions scattered across
> the tree.
>
> (1) Constant defines like these which can be unified across
>     with little effort.
>
> +#define KB (1UL << 10)
> +#define MB (1UL << 20)
> +#define GB (1UL << 30)
> +#define TB (1UL << 40)

Please don't add more/generalize (ab)users of decimal prefixes where
binary prefixes are needed/intended.

https://en.wikipedia.org/wiki/Binary_prefix

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
