Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F15226B01B4
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 01:20:44 -0400 (EDT)
Received: by gyg4 with SMTP id 4so2407058gyg.14
        for <linux-mm@kvack.org>; Sun, 06 Jun 2010 22:20:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTillFhDzhz06IXArHKbZCy9zBI5Isl4c2DiROXlz@mail.gmail.com>
References: <AANLkTilb4QNYznFeJVfMmvPAlBY-B02EY0i0d7NK9X7O@mail.gmail.com>
	<tnxvd9zcbr9.fsf@e102109-lin.cambridge.arm.com>
	<AANLkTillFhDzhz06IXArHKbZCy9zBI5Isl4c2DiROXlz@mail.gmail.com>
Date: Mon, 7 Jun 2010 13:20:42 +0800
Message-ID: <AANLkTikXdy6GOQ2EzDt-yrcJ_jMIPvLsH3neWBozpVCK@mail.gmail.com>
Subject: Re: mmotm 2010-06-03-16-36 lots of suspected kmemleak
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 4, 2010 at 9:55 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
> On Fri, Jun 4, 2010 at 6:50 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
>> Dave Young <hidave.darkstar@gmail.com> wrote:
>>> With mmotm 2010-06-03-16-36, I gots tuns of kmemleaks
>>
>> Do you have CONFIG_NO_BOOTMEM enabled? I posted a patch for this but
>> hasn't been reviewed yet (I'll probably need to repost, so if it fixes
>> the problem for you a Tested-by would be nice):
>>
>> http://lkml.org/lkml/2010/5/4/175
>
>
> I'd like to test, but I can not access the test pc during weekend. So
> I will test it next monday.

Bad news, the patch does not fix this issue.

>
> For CONFIG_NO_BOOTMEM, I don't remember. I guess set as 'y'

Confirmed, CONFIG_NO_BOOTMEM=y
>>
>> Thanks.
>>
>> --
>> Catalin
>>
>
> --
> Regards
> dave
>



-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
