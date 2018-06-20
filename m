Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7E76B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 19:05:54 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id r123-v6so565830ywe.10
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 16:05:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18-v6sor835104ybp.167.2018.06.20.16.05.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 16:05:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <778b2a1b-d810-815b-0fba-8a1d191acd49@infradead.org>
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
 <1529532570-21765-2-git-send-email-rick.p.edgecombe@intel.com>
 <12014310-19f7-dc31-d983-9c7e00c8b446@infradead.org> <CAGXu5j+RgbMKqiBcsWMOZ-ci-rT19imgCoHtPKgDURF1tC+COg@mail.gmail.com>
 <778b2a1b-d810-815b-0fba-8a1d191acd49@infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 20 Jun 2018 16:05:51 -0700
Message-ID: <CAGXu5j+TpZict=pSenHQ+_6V2fgoDrAGiB8sCd6bk-tb_Ec0zw@mail.gmail.com>
Subject: Re: [PATCH 1/3] vmalloc: Add __vmalloc_node_try_addr function
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, kristen Accardi <kristen.c.accardi@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Van De Ven, Arjan" <arjan.van.de.ven@intel.com>

On Wed, Jun 20, 2018 at 3:44 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 06/20/2018 03:35 PM, Kees Cook wrote:
>> On Wed, Jun 20, 2018 at 3:16 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
>>> On 06/20/2018 03:09 PM, Rick Edgecombe wrote:
>>>> +void *__vmalloc_node_try_addr(unsigned long addr, unsigned long size,
>>>> +                     gfp_t gfp_mask, pgprot_t prot, unsigned long vm_flags,
>>>> +                     int node, const void *caller)
>>>> +{
>>>
>>> so this isn't optional, eh?  You are going to force it on people because?
>>
>> RANDOMIZE_BASE isn't optional either. :) This improves the module
>> address entropy with (what seems to be) no down-side, so yeah, I think
>> it should be non-optional. :)
>
> In what kernel tree is RANDOMIZE_BASE not optional?

Oh, sorry, I misspoke: on by default. It _is_ possible to turn it off.

But patch #2 does check for RANDOMIZE_BASE, so it should work as expected, yes?

Or did you want even this helper function to be compiled out without it?

-Kees

-- 
Kees Cook
Pixel Security
