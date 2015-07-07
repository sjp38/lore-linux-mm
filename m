Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 09F7F2802C8
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 21:23:16 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so30097344pac.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 18:23:15 -0700 (PDT)
Received: from conssluserg004-v.nifty.com (conssluserg004.nifty.com. [202.248.44.42])
        by mx.google.com with ESMTPS id am4si31723012pad.93.2015.07.06.18.23.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jul 2015 18:23:14 -0700 (PDT)
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178]) (authenticated)
	by conssluserg004-v.nifty.com with ESMTP id t671MvTD022309
	for <linux-mm@kvack.org>; Tue, 7 Jul 2015 10:22:57 +0900
Received: by ykeo3 with SMTP id o3so44287966yke.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 18:22:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150706192525.GA16724@windriver.com>
References: <1436155277-21769-1-git-send-email-yamada.masahiro@socionext.com>
	<20150706192525.GA16724@windriver.com>
Date: Tue, 7 Jul 2015 10:22:56 +0900
Message-ID: <CAK7LNARUiVAaBTRPECeZrwfVMU=r6Pggc+eGx+6TUnzfufH98w@mail.gmail.com>
Subject: Re: [PATCH v2] mm: nommu: fix typos in comment blocks
From: Masahiro Yamada <yamada.masahiro@socionext.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>, Christoph Hellwig <hch@lst.de>, Leon Romanovsky <leon@leon.nu>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Paul

2015-07-07 4:25 GMT+09:00 Paul Gortmaker <paul.gortmaker@windriver.com>:
> [[PATCH v2] mm: nommu: fix typos in comment blocks] On 06/07/2015 (Mon 13:01) Masahiro Yamada wrote:
>
>> continguos -> contiguous
>>
>> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
>
> I'd suggested this go via the trivial tree, but instead I see it is in
> my inbox now, and still in everyone else's inbox, and yet not Cc'd to
> the trivial tree, which leaves me confused...
>
> Paul.


I found more misspelled "contiguous" in other files,
so this patch has been replaced with the following:

https://lkml.org/lkml/2015/7/6/954

The new one has been sent to Jiri Kosina.

-- 
Best Regards
Masahiro Yamada

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
