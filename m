Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA2CD6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 04:33:43 -0400 (EDT)
Received: by ladw1 with SMTP id w1so56068154lad.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 01:33:43 -0700 (PDT)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com. [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id i9si474269lae.58.2015.03.19.01.33.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 01:33:41 -0700 (PDT)
Received: by labjg1 with SMTP id jg1so56076568lab.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 01:33:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150228064647.GA9550@udknight.ahead-top.com>
References: <20150228064647.GA9550@udknight.ahead-top.com>
Date: Thu, 19 Mar 2015 11:33:41 +0300
Message-ID: <CALYGNiMLwhqQSmj58mT4MWk2RAuU-3TykoSd=XjuXVfqkL3NoA@mail.gmail.com>
Subject: Re: [RFC] Strange do_munmap in mmap_region
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang YanQing <udknight@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, yinghai@kernel.org.ahead-top.com, Andrew Morton <akpm@linux-foundation.org>

On Sat, Feb 28, 2015 at 9:46 AM, Wang YanQing <udknight@gmail.com> wrote:
> Hi Mel Gorman and all.
>
> I have read do_mmap_pgoff and mmap_region more than one hour,
> but still can't catch sense about below code in mmap_region:
>
> "
>         /* Clear old maps */
>         error = -ENOMEM;
> munmap_back:
>         if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
>                 if (do_munmap(mm, addr, len))
>                         return -ENOMEM;
>                 goto munmap_back;
>         }
> "
>
> How can we just do_munmap overlapping vma without check its vm_flags
> and new vma's vm_flags? I must miss some important things, but I can't
> figure out.
>
> You give below comment about the code in "understand the linux memory manager":)
>
> "
> If a VMA was found and it is part of the new mmapping, this removes the
>  old mmapping because the new one will cover both
> "
>
> But if new mmapping has different vm_flags or others' property, how
> can we just say the new one will cover both?
>
> I appreicate any clue and explanation about this headache question.
>
> Thanks.
>

Mmap() creates new mapping in given range
(new vma might be merged to one or both of sides if possible)
so everything what was here before is unmapped in process. Not?

>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
