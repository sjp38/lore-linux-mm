Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 092A82802BF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 11:19:42 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so107678811pdb.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 08:19:41 -0700 (PDT)
Received: from conssluserg003-v.nifty.com (conssluserg003.nifty.com. [202.248.44.41])
        by mx.google.com with ESMTPS id kp1si29446703pbd.216.2015.07.06.08.19.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jul 2015 08:19:41 -0700 (PDT)
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179]) (authenticated)
	by conssluserg003-v.nifty.com with ESMTP id t66FJHYf005234
	for <linux-mm@kvack.org>; Tue, 7 Jul 2015 00:19:18 +0900
Received: by ykfy125 with SMTP id y125so151448358ykf.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 08:19:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150706143713.GF11898@windriver.com>
References: <1436155277-21769-1-git-send-email-yamada.masahiro@socionext.com>
	<20150706143713.GF11898@windriver.com>
Date: Tue, 7 Jul 2015 00:19:16 +0900
Message-ID: <CAK7LNASW+vk6ts=2y-5CS3Vq9jSUYM_Z+qOK3KcQHmK+59WmzA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: nommu: fix typos in comment blocks
From: Masahiro Yamada <yamada.masahiro@socionext.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>, Christoph Hellwig <hch@lst.de>, Leon Romanovsky <leon@leon.nu>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Paul,

2015-07-06 23:37 GMT+09:00 Paul Gortmaker <paul.gortmaker@windriver.com>:
> [[PATCH v2] mm: nommu: fix typos in comment blocks] On 06/07/2015 (Mon 13:01) Masahiro Yamada wrote:
>
>> continguos -> contiguous
>>
>> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
>
> Perhaps in the future, it might not be a bad idea to feed such changes
> like this in via the trivial tree?   From MAINTAINERS:
>
> TRIVIAL PATCHES
> M:      Jiri Kosina <trivial@kernel.org>
> T:      git
> git://git.kernel.org/pub/scm/linux/kernel/git/jikos/trivial.git
> S:      Maintained


Uh, I did not know such a tree exist.

I found more typos in other sub-systems, so
I'd like to retract this patch,
and then re-send it to trivial.git along with other typo fixes.

Thanks,



-- 
Best Regards
Masahiro Yamada

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
