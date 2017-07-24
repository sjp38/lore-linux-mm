Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD98E6B02FA
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 10:04:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a2so151543640pgn.15
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 07:04:48 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0115.outbound.protection.outlook.com. [104.47.1.115])
        by mx.google.com with ESMTPS id d7si6717069pfb.637.2017.07.24.07.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 07:04:47 -0700 (PDT)
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
References: <CALCETrVpNUq3-zEu1Q1O77N8r4kv4kFdefXp7XEs3Hpf-JPAjg@mail.gmail.com>
 <d3caf8c4-4575-c1b5-6b0f-95527efaf2f9@virtuozzo.com>
 <f11d9e07-6b31-1add-7677-6a29d15ab608@virtuozzo.com>
 <20170711170332.wlaudicepkg35dmm@node.shutemov.name>
 <e9a395f4-018e-4c8c-2098-170172e438f3@virtuozzo.com>
 <20170711190554.zxkpjeg2bt65wtir@black.fi.intel.com>
 <20939b37-efd8-2d32-0040-3682fff927c2@virtuozzo.com>
 <20170713135228.vhvpe7mqdcqzpslw@node.shutemov.name>
 <20170713141528.rwuz5n2p57omq6wi@node.shutemov.name>
 <e201423e-5f4e-8bd6-144a-2374f7b7bb3f@virtuozzo.com>
 <20170724121331.k3fl4xjrsmznqk2t@node.shutemov.name>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ba973011-e46c-d034-00ee-77d494c62e5a@virtuozzo.com>
Date: Mon, 24 Jul 2017 17:07:08 +0300
MIME-Version: 1.0
In-Reply-To: <20170724121331.k3fl4xjrsmznqk2t@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>



On 07/24/2017 03:13 PM, Kirill A. Shutemov wrote:
> On Thu, Jul 13, 2017 at 05:19:22PM +0300, Andrey Ryabinin wrote:
>>>> https://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git/commit/?h=la57/boot-switching/v2&id=13327fec85ffe95d9c8a3f57ba174bf5d5c1fb01
>>>>
>>>>> As for KASAN, I think it would be better just to make it work faster,
>>>>> the patch below demonstrates the idea.
>>>>
>>>> Okay, let me test this.
>>>
>>> The patch works for me.
>>>
>>> The problem is not exclusive to 5-level paging, so could you prepare and
>>> push proper patch upstream?
>>>
>>
>> Sure, will do
> 
> Andrey, any follow up on this?
> 

Sorry, I've been busy a bit. Will send patch shortly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
