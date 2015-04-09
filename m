Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6137B6B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 19:22:42 -0400 (EDT)
Received: by iebmp1 with SMTP id mp1so4927472ieb.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 16:22:42 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id qr1si496071igb.16.2015.04.09.16.22.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 16:22:41 -0700 (PDT)
Received: by iedfl3 with SMTP id fl3so5509298ied.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 16:22:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1504091608410.21208@chino.kir.corp.google.com>
References: <3302342.cNyRUGN06P@wuerfel>
	<alpine.DEB.2.10.1504091230400.11370@chino.kir.corp.google.com>
	<6079838.EgducKeYG3@wuerfel>
	<alpine.DEB.2.10.1504091608410.21208@chino.kir.corp.google.com>
Date: Thu, 9 Apr 2015 16:22:41 -0700
Message-ID: <CA+r1Zhjq0UNnEKMz4mMgki_qCoo-zpSd7pxVYCNw6aXK2dJ=Vg@mail.gmail.com>
Subject: Re: [PATCH] mempool: add missing include
From: Jim Davis <jim.epost@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, Andrey Ryabinin <a.ryabinin@samsung.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Apr 9, 2015 at 4:12 PM, David Rientjes <rientjes@google.com> wrote:
> On Thu, 9 Apr 2015, Arnd Bergmann wrote:
>
>> > > This is a fix^3 for the mempool poisoning patch, which introduces
>> > > a compile-time error on some ARM randconfig builds:
>> > >
>> > > mm/mempool.c: In function 'check_element':
>> > > mm/mempool.c:65:16: error: implicit declaration of function 'kmap_atomic' [-Werror=implicit-function-declaration]
>> > >    void *addr = kmap_atomic((struct page *)element);
>> > >
>> > > The problem is clearly the missing declaration, and including
>> > > linux/highmem.h fixes it.
>> > >
>> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> > > Fixes: a3db5a8463b0db ("mm, mempool: poison elements backed by page allocator fix fix")
>> >
>> > Acked-by: David Rientjes <rientjes@google.com>
>> >
>> > Thanks!  Can you confirm that this is because CONFIG_BLOCK is disabled and
>> > not something else?
>>
>> Unfortunately I've lost the information which build was responsible
>> for this error (normally I keep it, but my script failed here because the
>> same config introduced two new regressions). CONFIG_BLOCK sounds plausible
>> here.
>>
>> If necessary, I can repeat the last few hundred builds without this
>> patch to find out what it was.
>>
>
> Ok, thanks.  The only reason I ask is because if this is CONFIG_BLOCK then
> it shouldn't be arm specific and nothing else has reported it.

The random configuration file included in
http://marc.info/?l=linux-mm&m=142851035816974&w=2 doesn't have
CONFIG_BLOCK set.  That build failure was on an x86_32 system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
