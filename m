Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2F96E6B026D
	for <linux-mm@kvack.org>; Sat,  9 Nov 2013 14:34:04 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so443510pbb.27
        for <linux-mm@kvack.org>; Sat, 09 Nov 2013 11:34:03 -0800 (PST)
Received: from psmtp.com ([74.125.245.118])
        by mx.google.com with SMTP id ei3si10670366pbc.350.2013.11.09.11.33.50
        for <linux-mm@kvack.org>;
        Sat, 09 Nov 2013 11:33:51 -0800 (PST)
Message-ID: <527E8E19.9030802@nod.at>
Date: Sat, 09 Nov 2013 20:33:45 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [uml-devel] fuzz tested 32 bit user mode linux image hangs in
 radix_tree_next_chunk()
References: <526696BF.6050909@gmx.de>	<CAFLxGvy3NeRKu+KQCCm0j4LS60PYhH0bC8WWjfiPvpstPBjAkA@mail.gmail.com>	<5266A698.10400@gmx.de>	<5266B60A.1000005@nod.at>	<52715AD1.7000703@gmx.de> <CALYGNiPvJF1u8gXNcX1AZR5-VkGqJnaose84KBbdaoBAq8aoGQ@mail.gmail.com> <527AB23D.2060305@gmx.de> <527AB51B.1020005@nod.at> <527E87EA.8080700@gmx.de>
In-Reply-To: <527E87EA.8080700@gmx.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>

Am 09.11.2013 20:07, schrieb Toralf FA?rster:
> On 11/06/2013 10:31 PM, Richard Weinberger wrote:
>> Am 06.11.2013 22:18, schrieb Toralf FA?rster:
>>> On 11/06/2013 05:06 PM, Konstantin Khlebnikov wrote:
>>>> In this case it must stop after scanning whole tree in line:
>>>> /* Overflow after ~0UL */
>>>> if (!index)
>>>>   return NULL;
>>>>
>>>
>>> A fresh current example with latest git tree shows that lines 769 and 770 do alternate :
>>
>> Can you please ask gdb for the value of offset?
>>
>> Thanks,
>> //richard
>>
> 
> Still trying to get those values. One attempt to do that was to replace -O2 with -O0 in the Makefile,
> but that resulted into this error :
> 
>   LD      kernel/built-in.o
>   CC      mm/memory.o
> In function a??zap_pmd_rangea??,
>     inlined from a??zap_pud_rangea?? at mm/memory.c:1265:8,
>     inlined from a??unmap_page_rangea?? at mm/memory.c:1290:8:
> mm/memory.c:1220:23: error: call to a??__compiletime_assert_1220a?? declared with attribute error: BUILD_BUG failed
> mm/memory.c: In function a??follow_page_maska??:
> mm/memory.c:1530:18: error: call to a??__compiletime_assert_1530a?? declared with attribute error: BUILD_BUG failed
> make[1]: *** [mm/memory.o] Error 1
> make: *** [mm] Error 2
> 
> 
> With -O1 it compiled at least.

You cannot build Linux with -O1/O0.
Try printing the value using printk...

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
