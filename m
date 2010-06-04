Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B8D6C6B01B4
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 09:55:07 -0400 (EDT)
Received: by pwi6 with SMTP id 6so160173pwi.14
        for <linux-mm@kvack.org>; Fri, 04 Jun 2010 06:55:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <tnxvd9zcbr9.fsf@e102109-lin.cambridge.arm.com>
References: <AANLkTilb4QNYznFeJVfMmvPAlBY-B02EY0i0d7NK9X7O@mail.gmail.com>
	<tnxvd9zcbr9.fsf@e102109-lin.cambridge.arm.com>
Date: Fri, 4 Jun 2010 21:55:05 +0800
Message-ID: <AANLkTillFhDzhz06IXArHKbZCy9zBI5Isl4c2DiROXlz@mail.gmail.com>
Subject: Re: mmotm 2010-06-03-16-36 lots of suspected kmemleak
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 4, 2010 at 6:50 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> Dave Young <hidave.darkstar@gmail.com> wrote:
>> With mmotm 2010-06-03-16-36, I gots tuns of kmemleaks
>
> Do you have CONFIG_NO_BOOTMEM enabled? I posted a patch for this but
> hasn't been reviewed yet (I'll probably need to repost, so if it fixes
> the problem for you a Tested-by would be nice):
>
> http://lkml.org/lkml/2010/5/4/175


I'd like to test, but I can not access the test pc during weekend. So
I will test it next monday.

For CONFIG_NO_BOOTMEM, I don't remember. I guess set as 'y'
>
> Thanks.
>
> --
> Catalin
>

-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
