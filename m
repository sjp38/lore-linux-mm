Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9641D6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 10:18:24 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id f14so60223675lbb.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 07:18:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k62si20361913wmf.79.2016.05.16.07.18.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 07:18:23 -0700 (PDT)
Subject: Re: x86: possible store-tearing in native_set_pte?
References: <BB81219D-9DAC-4A88-8029-C40E8D69D708@gmail.com>
 <C38292D5-A96B-41CA-B037-60D28326668A@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5739D6AE.6010501@suse.cz>
Date: Mon, 16 May 2016 16:18:22 +0200
MIME-Version: 1.0
In-Reply-To: <C38292D5-A96B-41CA-B037-60D28326668A@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>, linux-mm@kvack.org

On 04/26/2016 02:40 AM, Nadav Amit wrote:
> Resending with fixed formatting (sorry for that):
>
> Can someone please explain why it is ok for native_set_pte to assign
> the PTE without WRITE_ONCE() ?

You should probably ask also x86 maintainers/list. IMHO you might have a 
point, but I may be missing something.

> Isn't it possible for a PTE write to be torn, and the PTE to be
> prefetched in between (or even used for translation by another core)?
>
> I did not encounter this case, but it seems to me possible according
> to the documentation:
>
> Intel SDM 4.10.2.3 "Detail of TLB Use": "The processor may cache
> translations required for prefetches and for accesses ... that would
> never actually occur in the executed code path."
>
> Documentation/memory-barriers.txt: "The compiler is within its rights
> to invent stores to a variable".
>
> Thanks,
> Nadav
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
