Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 145F8440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 10:17:09 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g7so59760513pgp.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 07:17:09 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0101.outbound.protection.outlook.com. [104.47.0.101])
        by mx.google.com with ESMTPS id g8si4450938plj.549.2017.07.13.07.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Jul 2017 07:17:08 -0700 (PDT)
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
References: <CALCETrW6pWzpdf1MVx_ytaYYuVGBsF7R+JowEsKqd3i=vCwJ_w@mail.gmail.com>
 <20170711103548.mkv5w7dd5gpdenne@node.shutemov.name>
 <CALCETrVpNUq3-zEu1Q1O77N8r4kv4kFdefXp7XEs3Hpf-JPAjg@mail.gmail.com>
 <d3caf8c4-4575-c1b5-6b0f-95527efaf2f9@virtuozzo.com>
 <f11d9e07-6b31-1add-7677-6a29d15ab608@virtuozzo.com>
 <20170711170332.wlaudicepkg35dmm@node.shutemov.name>
 <e9a395f4-018e-4c8c-2098-170172e438f3@virtuozzo.com>
 <20170711190554.zxkpjeg2bt65wtir@black.fi.intel.com>
 <20939b37-efd8-2d32-0040-3682fff927c2@virtuozzo.com>
 <20170713135228.vhvpe7mqdcqzpslw@node.shutemov.name>
 <20170713141528.rwuz5n2p57omq6wi@node.shutemov.name>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <e201423e-5f4e-8bd6-144a-2374f7b7bb3f@virtuozzo.com>
Date: Thu, 13 Jul 2017 17:19:22 +0300
MIME-Version: 1.0
In-Reply-To: <20170713141528.rwuz5n2p57omq6wi@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>



On 07/13/2017 05:15 PM, Kirill A. Shutemov wrote:

>>
>> Hm. I don't see this:
>>
>> ...
>> [    0.247532] 0xff9e938000000000-0xff9f000000000000      111104G                               p4d
>> [    0.247733] 0xff9f000000000000-0xffff000000000000          24P                               pgd
>> [    0.248066] 0xffff000000000000-0xffffff0000000000         255T                               p4d
>> [    0.248290] ---[ ESPfix Area ]---
>> [    0.248393] 0xffffff0000000000-0xffffff8000000000         512G                               p4d
>> [    0.248663] 0xffffff8000000000-0xffffffef00000000         444G                               pud
>> [    0.248892] ---[ EFI Runtime Services ]---
>> [    0.248996] 0xffffffef00000000-0xfffffffec0000000          63G                               pud
>> [    0.249308] 0xfffffffec0000000-0xfffffffefe400000         996M                               pmd
>> ...
>>
>> Do you have commit "x86/dump_pagetables: Generalize address normalization"
>> in your tree?
>>

Nope. Applied now, it helped.

>> https://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git/commit/?h=la57/boot-switching/v2&id=13327fec85ffe95d9c8a3f57ba174bf5d5c1fb01
>>
>>> As for KASAN, I think it would be better just to make it work faster,
>>> the patch below demonstrates the idea.
>>
>> Okay, let me test this.
> 
> The patch works for me.
> 
> The problem is not exclusive to 5-level paging, so could you prepare and
> push proper patch upstream?
> 

Sure, will do

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
