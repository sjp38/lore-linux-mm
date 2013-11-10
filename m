Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id B70736B025B
	for <linux-mm@kvack.org>; Sun, 10 Nov 2013 10:46:08 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id up7so4126806pbc.40
        for <linux-mm@kvack.org>; Sun, 10 Nov 2013 07:46:08 -0800 (PST)
Received: from psmtp.com ([74.125.245.110])
        by mx.google.com with SMTP id ru9si13033246pbc.228.2013.11.10.07.46.05
        for <linux-mm@kvack.org>;
        Sun, 10 Nov 2013 07:46:06 -0800 (PST)
Message-ID: <527FAA34.8080307@nod.at>
Date: Sun, 10 Nov 2013 16:45:56 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [uml-devel] fuzz tested 32 bit user mode linux image hangs in
 radix_tree_next_chunk()
References: <526696BF.6050909@gmx.de>	<CAFLxGvy3NeRKu+KQCCm0j4LS60PYhH0bC8WWjfiPvpstPBjAkA@mail.gmail.com>	<5266A698.10400@gmx.de>	<5266B60A.1000005@nod.at>	<52715AD1.7000703@gmx.de> <CALYGNiPvJF1u8gXNcX1AZR5-VkGqJnaose84KBbdaoBAq8aoGQ@mail.gmail.com> <527AB23D.2060305@gmx.de> <527AB51B.1020005@nod.at> <527FA2BE.6090307@gmx.de>
In-Reply-To: <527FA2BE.6090307@gmx.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>

Am 10.11.2013 16:14, schrieb Toralf FA?rster:
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
> With this change 
> 
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 7811ed3..b2e9db5 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -767,6 +767,7 @@ restart:
>                                                 offset + 1);
>                         else
>                                 while (++offset < RADIX_TREE_MAP_SIZE) {
> +                                       printk ("node->slots[offset] %p offeset %lu\n", node->slots[offset], offset);
>                                         if (node->slots[offset])
>                                                 break;
>                                 }

Make sure that you print only in case of a enless loop. i.e. add a loop counter
and start printing only if the loop was taken *very* often.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
